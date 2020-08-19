//
// LWComplicationDataSourceBase.m
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockComplications/ClockComplications.h>
#import <ClockKit/ClockKit.h>

#import "CLKComplicationFamily.h"
#import "LWComplicationDataSourceBase.h"

#import "Core/LWPreferences.h"

@implementation LWComplicationDataSourceBase

+ (BOOL)acceptsComplicationType:(NSUInteger)type forDevice:(CLKDevice*)device {
	return YES;
}

+ (BOOL)acceptsComplicationFamily:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	return YES;
}

+ (NSString*)complicationApplicationIdentifierForComplicationType:(NTKComplicationType)complicationType {
	switch (complicationType) {
		case NTKComplicationTypeMediaRemote: return @"com.apple.Remote";
		case NTKComplicationTypeMessages: return @"com.apple.MobileSMS";
		case NTKComplicationTypePhone: return @"com.apple.mobilephone";
		case NTKComplicationTypeMaps: return @"com.apple.Maps";
		case NTKComplicationTypeNews: return @"com.apple.news";
		case NTKComplicationTypeMail: return @"com.apple.mobilemail";
		case NTKComplicationTypeHomeKit: return @"com.apple.Home";
		default: return nil;
	}
}

+ (Class)dataSourceClassForBundleComplication:(NTKBundleComplication*)bundleComplication {
	NSString* bundleIdentifier = bundleComplication.complication.bundleIdentifier;
	#define IS_COMPLICATION_BUNDLE(string) [bundleIdentifier isEqualToString:string]
	
	if (IS_COMPLICATION_BUNDLE(@"com.apple.NanoTimeKit.NTKCellularConnectivityComplicationDataSource")) {
		return NSClassFromString(@"LWCellularConnectivityComplicationDataSource");
	} else if (IS_COMPLICATION_BUNDLE(@"com.apple.weather.precipitation.chance")) {
		return NSClassFromString(@"LWChanceRainComplicationDataSource");
	}
	
	return nil;
}

+ (Class)dataSourceClassForComplicationType:(NTKComplicationType)type family:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	switch (type) {
		case NTKComplicationTypeDate: return NSClassFromString(@"LWDateComplicationDataSource");
		case NTKComplicationTypeAlarm: return NSClassFromString(@"LWAlarmComplicationDataSource");
		case NTKComplicationTypeTimer: return NSClassFromString(@"LWTimerComplicationDataSource");
		case NTKComplicationTypeStopwatch: break;
		case NTKComplicationTypeWorldClock: return NSClassFromString(@"LWWorldClockComplicationDataSource");
		case NTKComplicationTypeFindMy: break;
		case NTKComplicationTypeWellness: return NSClassFromString(@"LWWellnessComplicationDataSource");
		case NTKComplicationTypeNextEvent: break;
		case NTKComplicationTypeWeather: return NSClassFromString(@"LWWeatherDataSource");
		case NTKComplicationTypeMoonPhase: break;
		case NTKComplicationTypeSunrise: break;
		case NTKComplicationTypeBattery: return NSClassFromString(@"LWBatteryComplicationDataSource");
		case NTKComplicationTypeMonogram: break;
		case NTKComplicationTypeHeartBeat: break;
		case NTKComplicationTypeLunarDate: break;
		case NTKComplicationTypeMusic: return NSClassFromString(@"LWMusicComplicationDataSource");
		case NTKComplicationTypeWorkout: break;
		case NTKComplicationTypeBreathing: break;
		case NTKComplicationTypeReminders: break;
		case NTKComplicationTypeMediaRemote: break;
		case NTKComplicationTypeWeatherConditions: return NSClassFromString(@"LWConditionsDataSource");
		case NTKComplicationTypeMessages: break;
		case NTKComplicationTypePhone: break;
		case NTKComplicationTypeMaps: break;
		case NTKComplicationTypeNews: break;
		case NTKComplicationTypeMail: break;
		case NTKComplicationTypeHomeKit: break;
		case NTKComplicationTypeSiri: return NSClassFromString(@"LWSiriComplicationDataSource");
		case NTKComplicationTypeRemote: break;
		case NTKComplicationTypeConnectivity: break;
		case NTKComplicationTypeTinCan: break;
		case NTKComplicationTypeNowPlaying: return NSClassFromString(@"LWNowPlayingComplicationDataSource");
		case NTKComplicationTypeRadio: return NSClassFromString(@"LWRadioComplicationDataSource");
		case NTKComplicationTypeWeatherAirQuality: return NSClassFromString(@"LWAirQualityDataSource");
		case NTKComplicationTypePeople: break;
		case NTKComplicationTypeSolar: return NSClassFromString(@"LWSolarComplicationDataSource");
		case NTKComplicationTypeAstronomyEarth: 
		case NTKComplicationTypeAstronomyLuna:
		case NTKComplicationTypeAstronomyOrrery:
			return NSClassFromString(@"LWAstronomyComplicationDataSource");
		case NTKComplicationTypePodcast: return NSClassFromString(@"LWPodcastComplicationDataSource");
		case NTKComplicationTypeWeatherUVIndex: return NSClassFromString(@"LWUltravioletIndexDataSource");
		case NTKComplicationTypeWeatherWind: return NSClassFromString(@"LWWindDataSource");
		case NTKComplicationTypeDigitalTime: return NSClassFromString(@"LWDigitalTimeComplicationDataSource");
		case NTKComplicationTypeECG: break;
		case NTKComplicationTypeBundle: break;
		default: break;
	}
	
	return nil;
}

- (id)complicationApplicationIdentifier {
	return nil;
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return nil;
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	handler(nil);
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler(nil);
}

- (void)getSupportedTimeTravelDirectionsWithHandler:(void (^)(CLKComplicationTimeTravelDirections directions))handler {
	handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler {
	handler(NSDate.date);
}

- (void)getTimelineEntriesAfterDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler {
	handler(nil);
}

- (void)getTimelineEntriesBeforeDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler {
	handler(nil);
}

- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler {
	handler(NSDate.distantPast);
}

- (BOOL)supportsTapAction {
	return YES;
}

@end