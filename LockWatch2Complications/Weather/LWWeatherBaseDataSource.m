//
// LWWeatherBaseDataSource.m
// LockWatch
//
// Created by janikschmidt on 6/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <WeatherFoundation/WFAirQualityRequest.h>
#import <WeatherFoundation/WFForecastRequest.h>
#import <WeatherFoundation/WFDailyForecastRequest.h>
#import <WeatherFoundation/WFHourlyForecastRequest.h>
#import <WeatherFoundation/WFServiceConnection.h>
#import <WeatherFoundation/WFWeatherConditions.h>

#import "LWWeatherBaseDataSource.h"

@implementation LWWeatherBaseDataSource

+ (NSString*)appIdentifier {
	return @"com.apple.weather";
}

+ (NSString*)complicationLocalizationKey {
	return @"WEATHER";
}

+ (CGFloat)updateInterval {
	return 300;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_city = [self _activeCity];
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_localeChanged:) name:NSCurrentLocaleDidChangeNotification object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Instance Methods

- (void)__discardData {
	NSLog(@"discarding data");
	
	_currentAirQualityConditions = nil;
	_currentConditions = nil;
	_currentDayForecasts = nil;
	_currentHourlyForecasts = nil;
	
	_updateTimestamp = 0;
	
	[self _invalidate];
}

- (City*)_activeCity {
	WeatherPreferences* weatherPreferences = [WeatherPreferences sharedPreferences];
	
	if ([weatherPreferences isLocalWeatherEnabled] && [weatherPreferences loadActiveCity] == 0) {
		return [weatherPreferences localWeatherCity];
	}
	
	City* city;
	NSArray<City*>* savedCities = [weatherPreferences loadSavedCities];
	if (savedCities && savedCities.count) city = savedCities[[weatherPreferences loadActiveCity]];
	
	NSArray<City*>* defaultCities = [weatherPreferences _defaultCities];
	if (!city && defaultCities && defaultCities.count) city = defaultCities[[weatherPreferences loadDefaultSelectedCity]];

	return city;
}

- (void)_invalidate {
	[self.delegate invalidateSwitcherTemplate];
	[self.delegate invalidateEntries];
}

- (void)_localeChanged:(NSNotification*)notification {
	[self _invalidate];
}

- (NSDateComponents*)_nwkDateComponentsForDate:(NSDate*)date {
	return [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitCalendar | NSCalendarUnitTimeZone fromDate:date ? date : NSDate.date];
}

- (void)_startUpdateTimerIfNeeded {
	if (!_updateTimer) {
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:[LWWeatherBaseDataSource updateInterval] target:self selector:@selector(_updateIfNeeded) userInfo:nil repeats:YES];
	}
}

- (void)_stopUpdateTimer {
	if (_updateTimer) {
		[_updateTimer invalidate];
		_updateTimer = nil;
	}
}

- (void)_updateIfNeeded {
	if (time(NULL) - _updateTimestamp >= [LWWeatherBaseDataSource updateInterval]) {
		NSLog(@"updating");
		_isUpdating = YES;
		
		// _currentAirQualityConditions = nil;
		// _currentConditions = nil;
		// _currentDayForecasts = nil;
		// _currentHourlyForecasts = nil;
		
		// [self _invalidate];
		
		WFServiceConnection* serviceConnection = [WFTask sharedServiceConnection];
		dispatch_group_t dispatchGroup = dispatch_group_create();
		
		// Air Quality
		dispatch_group_enter(dispatchGroup);
		WFAirQualityRequest* airQualityRequest = [WFAirQualityRequest airQualityRequestForLocation:_city.wfLocation locale:[NSLocale autoupdatingCurrentLocale] completionHandler:^(WFAirQualityConditions* conditions) {
			NSLog(@"got air quality conditions: %@", conditions);
			_currentAirQualityConditions = conditions;
			
			dispatch_group_leave(dispatchGroup);
		}];
		[serviceConnection enqueueRequest:airQualityRequest];
		
		// Current Conditions
		dispatch_group_enter(dispatchGroup);
		WFForecastRequest* forecastRequest = [WFForecastRequest forecastRequestForLocation:_city.wfLocation date:[self _nwkDateComponentsForDate:NSDate.date] completionHandler:^(WFWeatherConditions* conditions) {
			NSLog(@"got conditions: %@", conditions);
			_currentConditions = conditions;
			
			dispatch_group_leave(dispatchGroup);
		}];
		[serviceConnection enqueueRequest:forecastRequest];
		
		// Day Forecasts
		dispatch_group_enter(dispatchGroup);
		WFDailyForecastRequest* dailyForecastRequest = [[WFDailyForecastRequest alloc] initWithLocation:_city.wfLocation completionHandler:^(NSArray<WFWeatherConditions*>* dayForecasts) {
			NSLog(@"got day forecasts: %@", dayForecasts);
			_currentDayForecasts = dayForecasts;
			
			dispatch_group_leave(dispatchGroup);
		}];
		[serviceConnection enqueueRequest:dailyForecastRequest];
		
		// Hourly Forecasts
		dispatch_group_enter(dispatchGroup);
		WFHourlyForecastRequest* hourlyForecastRequest = [[WFHourlyForecastRequest alloc] initWithLocation:_city.wfLocation completionHandler:^(NSArray<WFWeatherConditions*>* hourlyForecasts) {
			NSLog(@"got hourly forecasts: %@", hourlyForecasts);
			_currentHourlyForecasts = hourlyForecasts;
			
			dispatch_group_leave(dispatchGroup);
		}];
		[serviceConnection enqueueRequest:hourlyForecastRequest];
		
		
		
		dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
			NSLog(@"update completed");
			_isUpdating = NO;
			
			if (_currentAirQualityConditions && _currentConditions && _currentDayForecasts && _currentHourlyForecasts) {
    			_updateTimestamp = time(NULL);
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _invalidate];
			});
		});
		// dispatch_group_wait(dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)));
		// NSLog(@"update completed");
		// _updateTimestamp = time(NULL);
		// _isUpdating = NO;
		
		// [self _invalidate];
	}
}

#pragma mark - NTKComplicationDataSource

- (void)becomeActive {
	[self _invalidate];
	
	[self _startUpdateTimerIfNeeded];
	[self _updateIfNeeded];
}

- (void)becomeInactive {
	[self _stopUpdateTimer];
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!_switcherTemplate) {
		[self getCurrentTimelineEntryWithHandler:^(CLKComplicationTimelineEntry* timelineEntry) {
			_switcherTemplate = [timelineEntry complicationTemplate];
		}];
	}
	
	return _switcherTemplate;
}

- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler {
	if (_currentHourlyForecasts.count >= 5) {
		handler([NSCalendar.currentCalendar dateFromComponents:[_currentHourlyForecasts[4] objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"]]);
		return;
	}
	
	handler(NSDate.distantFuture);
}

- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler {
	if (_currentConditions) {
		handler([NSCalendar.currentCalendar dateFromComponents:[_currentConditions objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"]]);
		return;
	}
	
	handler(NSDate.distantPast);
}

- (void)pause {
	[self _stopUpdateTimer];
}

- (void)resume {
	[self _startUpdateTimerIfNeeded];
	[self _updateIfNeeded];
}

@end