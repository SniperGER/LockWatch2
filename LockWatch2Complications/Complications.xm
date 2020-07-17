//
// Complications.xm
// LockWatch2
//
// Created by janikschmidt on 3/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "Complications.h"

%group SpringBoard
%hook NTKComplicationDataSource
+ (Class)dataSourceClassForComplicationType:(unsigned long long)type family:(long long)family forDevice:(id)device {
	NSInteger complicationContent = [[%c(LWPreferences) sharedInstance] complicationContent];
	if (complicationContent == 0) {
		return nil;
	} else if (complicationContent == 1) {
		return %orig;
	}
	
	Class dataSourceClass;
	
	switch (type) {
		case NTKComplicationTypeDate: 
			dataSourceClass = %c(LWDateComplicationDataSource);
			break;
		case NTKComplicationTypeAlarm: break; // TODO
		case NTKComplicationTypeTimer: break; // TODO
		case NTKComplicationTypeStopwatch: break; // TODO
		case NTKComplicationTypeWorldClock:
			dataSourceClass= %c(LWWorldClockComplicationDataSource);
			break;
		case NTKComplicationTypeFindMy: break;
		case NTKComplicationTypeWellness: 
			dataSourceClass = %c(LWWellnessComplicationDataSource);
			break;
		case NTKComplicationTypeNextEvent: break; // TODO
		case NTKComplicationTypeWeather: 
			dataSourceClass = %c(LWWeatherDataSource);
			break;
		case NTKComplicationTypeMoonPhase: break; // TODO
		case NTKComplicationTypeSunrise: break; // TODO
		case NTKComplicationTypeBattery: 
			dataSourceClass = %c(LWBatteryComplicationDataSource);
			break;
		case NTKComplicationTypeMonogram: break; // TODO
		case NTKComplicationTypeHeartrate: break;
		case NTKComplicationTypeLunarDate: break; // TODO
		case NTKComplicationTypeMusic: break; // TODO
		case NTKComplicationTypeWorkout: break;
		case NTKComplicationTypeBreathing: break;
		case NTKComplicationTypeReminder: break; // TODO
		case NTKComplicationTypeMediaRemote: break;
		case NTKComplicationTypeWeatherConditions:
			dataSourceClass = %c(LWConditionsDataSource);
			break;
		case NTKComplicationTypeMessages: break;
		case NTKComplicationTypePhone: break;
		case NTKComplicationTypeMaps: break;
		case NTKComplicationTypeNews: break; // TODO
		case NTKComplicationTypeMail: break;
		case NTKComplicationTypeHomeKit: break;
		case NTKComplicationTypeSiri: break;
		case NTKComplicationTypeRemote: break;
		case NTKComplicationTypeConnectivity: break; // TODO
		case NTKComplicationTypeTinCan: break;
		case NTKComplicationTypeNowPlaying: 
			dataSourceClass = %c(LWNowPlayingComplicationDataSource);
			break;
		case NTKComplicationTypeRadio: break; // TODO
		case NTKComplicationTypeWeatherAirQuality: 
			dataSourceClass = %c(LWAirQualityDataSource);
			break;
		case NTKComplicationTypePeople: break;
		case NTKComplicationTypeSolar: break; // TODO
		case NTKComplicationTypeAstronomyEarth: break; // TODO
		case NTKComplicationTypeAstronomyLuna: break; // TODO
		case NTKComplicationTypeAstronomyOrrery: break; // TODO
		case NTKComplicationTypePodcast: break;
		case NTKComplicationTypeWeatherUVIndex:
			dataSourceClass = %c(LWUltravioletIndexDataSource);
			break;
		case NTKComplicationTypeWeatherWind:
			dataSourceClass = %c(LWWindDataSource);
			break;
		case NTKComplicationTypeDigitalTime:
			dataSourceClass = %c(LWDigitalTimeComplicationDataSource);
			break;
		case NTKComplicationTypeECG: break;
		case NTKComplicationTypeBundle: break;
		default: break;
	}
	
	BOOL acceptsComplicationFamily = YES;
	if (dataSourceClass) {
		LWComplicationDataSourceBase* instance = [[dataSourceClass alloc] init];
		acceptsComplicationFamily = [instance.class acceptsComplicationFamily:family forDevice:device];
	}
	
	if (complicationContent == 2) {
		if (dataSourceClass && acceptsComplicationFamily) return dataSourceClass;
		return %orig;
	}
	
	if (!acceptsComplicationFamily) return nil;
	return dataSourceClass;
}
%end	/// %hook NTKComplicationDataSource

%hook NTKTimelineDataOperation
- (void)start {
	if ([MSHookIvar<NSObject*>(self, "_localDataSource") isKindOfClass:%c(LWComplicationDataSourceBase)]) {
		%orig;
	}
	
	return;
}
%end	/// %hook NTKTimelineDataOperation

%hook NTKWellnessEntryModel
- (BOOL)userHasDoneActivitySetup {
	return YES;
}

- (BOOL)databaseLoading {
	return NO;
}
%end	/// %hook NTKWellnessEntryModel

%hook NTKWellnessTimelineModel
- (void)_queue_startQueries {
	MSHookIvar<NSDate*>(self, "_currentDate") = [NSDate date];
	
	_HKCurrentActivitySummaryQuery* summaryQuery = [[objc_getClass("_HKCurrentActivitySummaryQuery") alloc] initWithUpdateHandler:^(_HKCurrentActivitySummaryQuery* query, HKActivitySummary* activitySummary, NSError* error) {
		if (!error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _queue_updateCurrentActivitySummaryWithSummary:activitySummary];
			});
		}
	}];
	MSHookIvar<_HKCurrentActivitySummaryQuery*>(self, "_queue_currentActivitySummaryQuery") = summaryQuery;
	[summaryQuery _setCollectionIntervals:[self _currentActivitySummaryQueryCollectionIntervalsOverride]];
	[MSHookIvar<HKHealthStore*>(self, "_healthStore") executeQuery:summaryQuery];
	
	NSDateComponents* dateComponents = [NSDateComponents new];
	[dateComponents setSecond:1800];
	
	HKCurrentActivityCacheQuery* cacheQuery = [[objc_getClass("HKCurrentActivityCacheQuery") alloc] initWithStatisticsIntervalComponents:dateComponents updateHandler:^(HKCurrentActivityCacheQuery* query, id result, NSError* error) {
		if (!error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _queue_updateChartStatisticsWithStatisticsQueryResult:result];
			});
		}
	}];
	MSHookIvar<id>(self, "_queue_currentActivityCacheQuery") = cacheQuery;
	[MSHookIvar<HKHealthStore*>(self, "_healthStore") executeQuery:cacheQuery];
}
%end	/// %hook NTKWellnessTimelineModel

%hook WFWeatherConditions
- (BOOL)isNightForecast {
	BOOL r = %orig;
	
	if (!r && [self valueForComponent:@"WFWeatherSunriseTimeComponent"] && [self valueForComponent:@"WFWeatherSunsetTimeComponent"]) {
		NSDate* currentDate = [NSDate date];
		NSDate* sunriseTime = [[NSCalendar currentCalendar] dateFromComponents:(NSDateComponents*)[self valueForComponent:@"WFWeatherSunriseTimeComponent"]];
		NSDate* sunsetTime = [[NSCalendar currentCalendar] dateFromComponents:(NSDateComponents*)[self valueForComponent:@"WFWeatherSunsetTimeComponent"]];
		
		return [currentDate compare:sunriseTime] == NSOrderedAscending || [currentDate compare:sunsetTime] == NSOrderedDescending;
	}
	
	return r;
}

- (id)nwc_conditionImageForComplicationFamily:(NSInteger)arg1 {
	if (!self.isNightForecast) {
		return [self nwc_daytimeConditionImageForComplicationFamily:arg1];
	} else {
		return [self nwc_nighttimeConditionImageForComplicationFamily:arg1];
	}
}
%end	/// %hook WFWeatherConditions
%end	// %group SpringBoard



%group healthd
static HDActivityCacheManager* activityCacheManager;

%hook HDPrimaryProfile
- (id)activityCacheManager {
	HDActivityCacheManager* r = %orig;
	
	if (!r) {
		activityCacheManager = [[%c(HDActivityCacheManager) alloc] initWithProfile:self];
		return activityCacheManager;
	}
	
	return r;
}
%end

%hook HDReadAuthorizationStatus
- (long long)authorizationStatus {
	return 1;
}
%end
%end	// %group healthd



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [%c(LWPreferences) sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/WeatherComplicationsCompanion.bundle/WeatherComplicationsCompanion", RTLD_NOW);
				
				%init(SpringBoard);
			}
			
			if ([bundleIdentifier isEqualToString:@"com.apple.healthd"] || [bundleIdentifier isEqualToString:@"com.apple.HealthKit"]) {
				%init(healthd);
			}
		}
	}
}