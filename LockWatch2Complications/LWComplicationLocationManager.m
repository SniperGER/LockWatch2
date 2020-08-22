//
// LWComplicationLocationManager.m
// LockWatch
//
// Created by janikschmidt on 8/15/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationLocationManager.h"

@interface CLInUseAssertion : NSObject
+ (instancetype)newAssertionForBundle:(id)arg1 withReason:(id)arg2;
- (void)invalidate;
@end

@interface CLLocationManager (Private)
+ (CLAuthorizationStatus)authorizationStatusForBundle:(id)arg1;
- (BOOL)_isGroundAltitudeEnabled;
- (void)_setGroundAltitudeEnabled:(BOOL)arg1;
- (BOOL)_startMonitoringSignificantLocationChangesOfDistance:(CGFloat)arg1 withPowerBudget:(int)arg2;
- (id)initWithEffectiveBundle:(id)arg1;
- (void)requestWhenInUseAuthorizationWithPrompt;
@end

extern NSBundle* NTKLocationBundle();

@implementation LWComplicationLocationManager



+ (CLLocation*)_locationFromDefaults {
	NSData* locationData = (__bridge NSData*)CFPreferencesCopyAppValue(CFSTR("LWComplicationLocationManagerLastLocationKey"), CFSTR("ml.festival.lockwatch2.location"));

	if (locationData) {
		CLLocation* location = [NSKeyedUnarchiver unarchivedObjectOfClass:NSClassFromString(@"CLLocation") fromData:locationData error:nil];
		
		if (location) return location;
	}
	
	return nil;
}

+ (void)_saveLocationIntoDefaultsWithLocation:(CLLocation*)location {
	if (location) {
		NSData* locationData = [NSKeyedArchiver archivedDataWithRootObject:location requiringSecureCoding:YES error:nil];
		if (locationData) {
			CFPreferencesSetAppValue(CFSTR("LWComplicationLocationManagerLastLocationKey"), (__bridge CFDataRef)locationData, CFSTR("ml.festival.lockwatch2.location"));
		}
	} else {
		CFPreferencesSetAppValue(CFSTR("LWComplicationLocationManagerLastLocationKey"), NULL, CFSTR("ml.festival.lockwatch2.location"));
	}
}

- (instancetype)init {
	if (self = [super init]) {
		_queue = dispatch_queue_create("com.apple.NanoTimeKit.NTKCarouselLocationManager", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0));
		dispatch_suspend(_queue);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_locationManager = [[CLLocationManager alloc] initWithEffectiveBundle:NTKLocationBundle()];
			[_locationManager setDelegate:self];
			
			dispatch_resume(_queue);
		});
		
		_previousLocation = [LWComplicationLocationManager _locationFromDefaults];
		_locationUpdateHandlers = [NSMutableDictionary dictionary];
		_locationAccessLock = [NSLock new];
		_tokenAccessLock = [NSLock new];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)_cancelMonitoring {
	dispatch_assert_queue(_queue);
	
	if (_state <= LWComplicationLocationManagerStateMonitoring) {
		[_locationManager stopMonitoringSignificantLocationChanges];
		[_locationManager stopUpdatingLocation];
		
		[_locationInUseAssertion invalidate];
		_locationInUseAssertion = nil;
		
		_state = LWComplicationLocationManagerStateIdle;
	}
}

- (void)_didReceiveLocation:(CLLocation*)location {
	dispatch_assert_queue(_queue);
	
	[self _updateLocation:location];
	[LWComplicationLocationManager _saveLocationIntoDefaultsWithLocation:location];
	[self _notifyUpdateHandlersWithError:nil];
	
	CLLocation* previousLocation = [self previousLocation];
	if (!previousLocation || [previousLocation distanceFromLocation:location] >= 5000) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NTKLocationManagerSignificantLocationChangeNotification" object:nil];
	}
}

- (void)_discardLocations {
	dispatch_assert_queue(_queue);
	
	[_locationAccessLock lock];
	_currentLocation = nil;
	_previousLocation = nil;
	[_locationAccessLock unlock];
	
	[LWComplicationLocationManager _saveLocationIntoDefaultsWithLocation:nil];
	[self _notifyUpdateHandlersWithError:nil];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NTKLocationManagerSignificantLocationChangeNotification" object:nil];
	});
}

- (void)_notifyUpdateHandlersWithError:(NSError* _Nullable)error {
	dispatch_assert_queue(_queue);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		CLLocation* currentLocation = [self currentLocation];
		CLLocation* anyLocation = [self anyLocation];
		
		[_locationUpdateHandlers.allValues enumerateObjectsUsingBlock:^(LWComplicationLocationManagerHandler* locationHandler, NSUInteger index, BOOL* stop) {
			locationHandler.handler(currentLocation, anyLocation, error);
		}];
	});
}

- (void)_requestMonitoringIfPossible {
	dispatch_assert_queue(_queue);
	
	if (_state == LWComplicationLocationManagerStateIdle) {
		_state = LWComplicationLocationManagerStatePreparing;
		
		if ([CLLocationManager authorizationStatusForBundle:NTKLocationBundle()] == kCLAuthorizationStatusNotDetermined) {
			_state = LWComplicationLocationManagerStateIdle;
			[_locationManager requestWhenInUseAuthorizationWithPrompt];
		} else if ([CLLocationManager authorizationStatusForBundle:NTKLocationBundle()] >= kCLAuthorizationStatusAuthorizedAlways) {
			_state = LWComplicationLocationManagerStateReady;
			[self _startMonitoring];
		} else {
			_state = LWComplicationLocationManagerStateIdle;
		}
	}
}

- (void)_startMonitoring {
	dispatch_assert_queue(_queue);
	
	if (_state == LWComplicationLocationManagerStateReady) {
		_state = LWComplicationLocationManagerStateMonitoring;
		
		_locationInUseAssertion = [CLInUseAssertion newAssertionForBundle:NTKLocationBundle() withReason:@"Requesting location for Watch Faces"];
		[_locationManager _startMonitoringSignificantLocationChangesOfDistance:1000 withPowerBudget:1];
		
		if (![self currentLocation]) {
			[_locationManager requestLocation];
		}
	}
}

- (void)_updateGroundElevationRequesting {
	__block BOOL shouldRequestGroundElevation = NO;
	
	[_locationUpdateHandlers enumerateKeysAndObjectsUsingBlock:^(NSString* key, LWComplicationLocationManagerHandler* locationHandler, BOOL* stop) {
		if ([locationHandler wantsGroundLocation]) {
			shouldRequestGroundElevation = YES;
			*stop = YES;
		}
	}];
	
	if (shouldRequestGroundElevation) {
		if (![_locationManager _isGroundAltitudeEnabled]) {
			[_locationManager _setGroundAltitudeEnabled:YES];
		}
	} else if ([_locationManager _isGroundAltitudeEnabled]) {
		[_locationManager _setGroundAltitudeEnabled:NO];
	}
}

- (void)_updateLocation:(CLLocation*)location {
	dispatch_assert_queue(_queue);
	
	[_locationAccessLock lock];
	_currentLocation = location;
	[_locationAccessLock unlock];
}

- (CLLocation*)anyLocation {
	CLLocation* location = [self currentLocation];
	if (!location) location = [self previousLocation];
	if (!location) location = [LWComplicationLocationManager fallbackLocation];
	
	return location;
}

- (CLLocation*)currentLocation {
	[_locationAccessLock lock];
	CLLocation* location = _currentLocation;
	[_locationAccessLock unlock];
	
	return location;
}

- (CLLocation*)previousLocation {
	[_locationAccessLock lock];
	CLLocation* location = _previousLocation;
	[_locationAccessLock unlock];
	
	return location;
}

- (NSString*)startLocationUpdatesWithIdentifier:(NSString*)identifier handler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler {
	return [self startLocationUpdatesWithIdentifier:identifier wantsGroundElevation:NO handler:handler];
}

- (NSString*)startLocationUpdatesWithIdentifier:(NSString*)identifier wantsGroundElevation:(BOOL)wantsGroundElevation handler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler {
	NSString* token;
	
	if (identifier && handler) {
		[_tokenAccessLock lock];
		token = [NSString stringWithFormat:@"%@.%lu", identifier, _handlerCounter];
		[_tokenAccessLock unlock];
		
		dispatch_async(_queue, ^{
			LWComplicationLocationManagerHandler* locationHandler = [[LWComplicationLocationManagerHandler alloc] initWithWantsGroundLocation:wantsGroundElevation handler:handler];
			[_locationUpdateHandlers setObject:locationHandler forKeyedSubscript:token];
			
			[self _updateGroundElevationRequesting];
			
			if (_state == LWComplicationLocationManagerStateIdle) {
				[self _requestMonitoringIfPossible];
			}
		});
		
		dispatch_async(dispatch_get_main_queue(), ^{
			CLLocation* currentLocation = [self currentLocation];
			CLLocation* anyLocation = [self anyLocation];
			
			handler(currentLocation, anyLocation, nil);
		});
	}
	
	return token;
}

- (void)stopLocationUpdatesForToken:(NSString*)token {
	if (token) {
		dispatch_async(_queue, ^{
			[_locationUpdateHandlers removeObjectForKey:token];
			
			[self _updateGroundElevationRequesting];
			
			if (_locationUpdateHandlers.count == 0 && _state != LWComplicationLocationManagerStateIdle) {
				[self _cancelMonitoring];
			}
		});
	}
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	dispatch_async(_queue, ^{
		if (status >= kCLAuthorizationStatusAuthorizedAlways) {
			[self _requestMonitoringIfPossible];
		} else {
			[self _cancelMonitoring];
			[self _discardLocations];
		}
	});
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	dispatch_async(_queue, ^{
		[self _updateLocation:nil];
		[self _notifyUpdateHandlersWithError:error];
	});
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	_lastLocationUpdateDate = [NSDate date];
	
	dispatch_async(_queue, ^{
		CLLocation* location = [locations lastObject];
		CLLocation* currentLocation = [self currentLocation];
		
		if (currentLocation) {
			if ([currentLocation distanceFromLocation:location] > 0.01) {
				[self _didReceiveLocation:location];
			}
		} else {
			[self _didReceiveLocation:location];
		}
	});
}

@end