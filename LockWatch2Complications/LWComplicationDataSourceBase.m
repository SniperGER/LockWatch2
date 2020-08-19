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
	}
	
	return nil;
}

+ (Class)dataSourceClassForComplicationType:(NTKComplicationType)type family:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	switch (type) {
		case NTKComplicationTypeDate: 
			return NSClassFromString(@"LWDateComplicationDataSource");
			break;
		case NTKComplicationTypeAlarm: break; // TODO
		case NTKComplicationTypeTimer: break; // TODO
		case NTKComplicationTypeStopwatch: break; // TODO
		case NTKComplicationTypeWorldClock:
			return NSClassFromString(@"LWWorldClockComplicationDataSource");
			break;
		case NTKComplicationTypeFindMy: break;
		case NTKComplicationTypeWellness: 
			return NSClassFromString(@"LWWellnessComplicationDataSource");
			break;
		case NTKComplicationTypeNextEvent: break; // TODO
		case NTKComplicationTypeWeather: 
			return NSClassFromString(@"LWWeatherDataSource");
			break;
		case NTKComplicationTypeMoonPhase: break; // TODO
		case NTKComplicationTypeSunrise: break; // TODO
		case NTKComplicationTypeBattery: 
			return NSClassFromString(@"LWBatteryComplicationDataSource");
			break;
		case NTKComplicationTypeHeartrate: break;
		case NTKComplicationTypeLunarDate: break; // TODO
		case NTKComplicationTypeMusic:
			return NSClassFromString(@"LWMusicComplicationDataSource");
			break;
		case NTKComplicationTypeWorkout: break;
		case NTKComplicationTypeBreathing: break;
		case NTKComplicationTypeReminder: break; // TODO
		case NTKComplicationTypeMediaRemote: break;
		case NTKComplicationTypeWeatherConditions:
			return NSClassFromString(@"LWConditionsDataSource");
			break;
		case NTKComplicationTypeMessages: break; // TODO
		case NTKComplicationTypePhone: break; // TODO
		case NTKComplicationTypeMaps: break; // TODO
		case NTKComplicationTypeNews: break; // TODO
		case NTKComplicationTypeMail: break; // TODO
		case NTKComplicationTypeHomeKit: break; // TODO
		case NTKComplicationTypeSiri: break; // TODO
		case NTKComplicationTypeRemote: break;
		case NTKComplicationTypeTinCan: break;
		case NTKComplicationTypeNowPlaying: 
			return NSClassFromString(@"LWNowPlayingComplicationDataSource");
			break;
		case NTKComplicationTypeRadio:
			return NSClassFromString(@"LWRadioComplicationDataSource");
			break;
		case NTKComplicationTypeWeatherAirQuality: 
			return NSClassFromString(@"LWAirQualityDataSource");
			break;
		case NTKComplicationTypePeople: break; // TODO
		case NTKComplicationTypeSolar: break; // TODO
		case NTKComplicationTypeAstronomyEarth: break; // TODO
		case NTKComplicationTypeAstronomyLuna: break; // TODO
		case NTKComplicationTypeAstronomyOrrery: break; // TODO
		case NTKComplicationTypePodcast:
			return NSClassFromString(@"LWPodcastComplicationDataSource");
			break;
		case NTKComplicationTypeWeatherUVIndex:
			return NSClassFromString(@"LWUltravioletIndexDataSource");
			break;
		case NTKComplicationTypeWeatherWind:
			return NSClassFromString(@"LWWindDataSource");
			break;
		case NTKComplicationTypeDigitalTime:
			return NSClassFromString(@"LWDigitalTimeComplicationDataSource");
			break;
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