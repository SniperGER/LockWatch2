//
// LWAstronomyComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <CoreLocation/CLLocation.h>

#import "LWAstronomyComplicationDataSource.h"

extern NSDate* NTKIdealizedDate();

@implementation LWAstronomyComplicationDataSource

+ (BOOL)acceptsComplicationFamily:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	return family == CLKComplicationFamilyGraphicBezel || family == CLKComplicationFamilyGraphicCircular;
}

- (instancetype)initWithComplication:(NTKAstronomyComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_vista = [complication vista];
		
		_currentLocation = [[NTKLocationManager sharedLocationManager] currentLocation];
		_anyLocation = [[NTKLocationManager sharedLocationManager] anyLocation];
		
		[self _startObserving];
	}
	
	return self;
}

- (void)dealloc {
	[self _stopObserving];
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_currentTimelineEntryWithIdealizedDate:(BOOL)idealizedDate {
	NSDate* entryDate = [NSDate date];
	
	NTKAstronomyTimelineEntryModel* entryModel = [[NTKAstronomyTimelineEntryModel alloc] initWithVista:_vista entryDate:entryDate currentDate:(idealizedDate ? NTKIdealizedDate() : entryDate) currentLocation:_currentLocation anyLocation:_anyLocation];
	return [entryModel entryForComplicationFamily:self.family];
}

- (void)_invalidate {
	[self.delegate invalidateEntries];
}

- (void)_handleLocationUpdate:(CLLocation*)currentLocation anyLocation:(CLLocation*)anyLocation {
	/// TODO: Fix location manager to actually update our location
	_currentLocation = currentLocation;
	_anyLocation = anyLocation;
	
	[self _invalidate];
}

- (void)_startObserving {
	if (!_listeningForNotifications) {
		_listeningForNotifications = YES;
		
		[[CLKNotificationCenter defaultCenter] addObserver:self selector:@selector(_invalidate) notificationName:UIApplicationSignificantTimeChangeNotification];
		[[CLKNotificationCenter defaultCenter] addObserver:self selector:@selector(_invalidate) notificationName:NSCalendarDayChangedNotification];
		[[CLKNotificationCenter defaultCenter] addObserver:self selector:@selector(_invalidate) notificationName:NSCurrentLocaleDidChangeNotification];
	}
}

- (void)_stopObserving {
	_listeningForNotifications = NO;
	
	[[CLKNotificationCenter defaultCenter] removeObserver:self notificationName:UIApplicationSignificantTimeChangeNotification];
	[[CLKNotificationCenter defaultCenter] removeObserver:self notificationName:NSCalendarDayChangedNotification];
	[[CLKNotificationCenter defaultCenter] removeObserver:self notificationName:NSCurrentLocaleDidChangeNotification];
}

#pragma mark - NTKComplicationDataSource

- (BOOL)alwaysShowIdealizedTemplateInSwitcher {
	return YES;
}

- (void)becomeActive {
	_token = [[NTKLocationManager sharedLocationManager] startLocationUpdatesWithIdentifier:@"ntk.astronomyComplicationDataSource" handler:^(CLLocation* currentLocation, CLLocation* anyLocation) {
		[self _handleLocationUpdate:currentLocation anyLocation:anyLocation];
	}];
}

- (void)becomeInactive {
	if (_token) {
		[[NTKLocationManager sharedLocationManager] stopLocationUpdatesForToken:_token];
	}
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [[self _currentTimelineEntryWithIdealizedDate:YES] complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	handler([self _currentTimelineEntryWithIdealizedDate:NO]);
}

- (void)pause {
	[self _stopObserving];
}

- (void)resume {
	[self _startObserving];
	[self _invalidate];
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case CLKComplicationFamilyGraphicCorner:
			return NSClassFromString(@"NTKAstronomyRichComplicationCornerView");
		case CLKComplicationFamilyGraphicBezel:
			return NSClassFromString(@"NTKAstronomyRichComplicationBezelCircularView");
		case CLKComplicationFamilyGraphicCircular:
			return NSClassFromString(@"NTKAstronomyRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

- (BOOL)supportsTapAction {
	return NO;
}

@end