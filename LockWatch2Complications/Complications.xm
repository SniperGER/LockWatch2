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

%hook NTKLocalTimelineComplicationController
- (void)performTapAction {
	CLKCComplicationDataSource* dataSource = MSHookIvar<CLKCComplicationDataSource*>(self, "_dataSource");
	if (!dataSource) return;
	
	[dataSource getLaunchURLForTimelineEntryDate:nil timeTravelDate:nil withHandler:^(NSURL* url) {
		SBApplication* destinationApplication = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:dataSource.complicationApplicationIdentifier];
		
		if (!destinationApplication) return;
		
		SBLockScreenUnlockRequest* request = [%c(SBLockScreenUnlockRequest) new];
		[request setSource:17];
		[request setIntent:3];
		[request setName:[NSString stringWithFormat:@"SBWorkspaceRequest: Open \"%@\"", dataSource.complicationApplicationIdentifier]];
		[request setDestinationApplication:destinationApplication];
		[request setWantsBiometricPresentation:YES];
		[request setForceAlertAuthenticationUI:YES];
		
		FBSOpenApplicationService* appService = [%c(FBSOpenApplicationService) serviceWithDefaultShellEndpoint];
		
		[[%c(SBLockScreenManager) sharedInstance] unlockWithRequest:request completion:^(BOOL completed){
			if (completed) {
				if (url) {
					FBSOpenApplicationOptions* openOptions = [%c(FBSOpenApplicationOptions) optionsWithDictionary:@{
						@"__PayloadURL": url
					}];
					
					[appService openApplication:[dataSource complicationApplicationIdentifier] withOptions:openOptions completion:nil];
				} else {
					[appService openApplication:[dataSource complicationApplicationIdentifier] withOptions:nil completion:nil];
				}
			}
		}];
	}];
}
%end	/// %hook NTKLocalTimelineComplicationController

%hook NTKRichComplicationView
- (void)setHighlighted:(BOOL)arg1 {
	if (MSHookIvar<BOOL>(self, "_highlighted") != arg1) {
		MSHookIvar<BOOL>(self, "_highlighted") = arg1;
		
		[UIView animateWithDuration:(arg1 ? 0.05 : 0.2) animations:^{
			if (arg1) {
				[self setAlpha:0.3];
				[self setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
			} else {
				[self setAlpha:1];
				[self setTransform:CGAffineTransformIdentity];
			}
		}];
	}
}
%end	/// %hook NTKRichComplicationView

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



%group WeatherComplications
%hook WFWeatherConditions
- (BOOL)isNightForecast {
	BOOL r = %orig;
	
	if ([self valueForComponent:@"WFWeatherSunriseTimeComponent"] && [self valueForComponent:@"WFWeatherSunsetTimeComponent"]) {
		NSCalendar* calendar = [NSCalendar currentCalendar];
		
		NSDate* forecastTime = [calendar dateFromComponents:(NSDateComponents*)[self valueForComponent:@"WFWeatherForecastTimeComponent"]];
		NSDate* sunriseTime = [calendar dateFromComponents:(NSDateComponents*)[self valueForComponent:@"WFWeatherSunriseTimeComponent"]];
		NSDate* sunsetTime = [calendar dateFromComponents:(NSDateComponents*)[self valueForComponent:@"WFWeatherSunsetTimeComponent"]];
		
		return 
			([calendar isDateInToday:sunriseTime] && [forecastTime timeIntervalSinceReferenceDate] < [sunriseTime timeIntervalSinceReferenceDate]) || 
			([calendar isDateInToday:sunsetTime] && [forecastTime timeIntervalSinceReferenceDate] >= [sunsetTime timeIntervalSinceReferenceDate]);
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

- (CLKImageProvider*)nwc_conditionImageProviderForComplicationFamily:(NSInteger)arg1 {
	static NSBundle* localizationBundle = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		localizationBundle = [NSBundle bundleForClass:NSClassFromString(@"NWCCompanionBaseDataSource")];
	});
	
	if (!localizationBundle) return nil;
	
	BOOL isDay = !self.isNightForecast;
	NSInteger conditionCode = [self _nwc_code];
	NSString* familyPrefix = [WFWeatherConditions _nwc_prefixForFamily:arg1];
	
	NSString* imageName;
	switch (conditionCode) {
		case 1:
			imageName = @"tornado";
			break;
		case 2:
			imageName = @"tropical_storm";
			break;
		case 3:
			imageName = @"hurricane";
			break;
		case 4:
			imageName = [@"severe_thunderstorm" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 5:
			imageName = [@"scattered_thunderstorm" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 6:
			imageName = @"flurry_snow_shower";
			break;
		case 7:
			imageName = @"flurry_snow_shower";
			break;
		case 8:
			imageName = @"flurry_snow_shower";
			break;
		case 9:
			imageName = @"flurry_snow_shower";
			break;
		case 10:
			imageName = [@"drizzle" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 11:
			imageName = @"ice";
			break;
		case 12:
			imageName = [@"rain" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 13:
			imageName = [@"rain" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 14:
			imageName = @"flurry";
			break;
		case 15:
			imageName = @"flurry";
			break;
		case 16:
			imageName = @"blowing_snow";
			break;
		case 17:
			imageName = @"flurry";
			break;
		case 18:
			imageName = [@"hail" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 19:
			imageName = [@"sleet" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 20:
			imageName = @"dust";
			break;
		case 21:
			imageName = [@"fog" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 22:
			imageName = @"haze";
			break;
		case 23:
			imageName = @"smoke";
			break;
		case 24:
			imageName = @"breezy";
			break;
		case 25:
			imageName = @"breezy";
			break;
		case 26:
			imageName = @"ice";
			break;
		case 27:
			imageName = [@"mostly_cloudy" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 29:
			imageName = [@"mostly_cloudy" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 31:
			imageName = [@"partly_cloudy" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 33:
			imageName = (isDay ? @"mostly_sunny" : @"clear_night");
			break;
		case 35:
			imageName = (isDay ? @"mostly_sunny" : @"clear_night");
			break;
		case 36:
			imageName = [@"hail" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 37:
			imageName = @"hot";
			break;
		case 38:
			imageName = [@"scattered_thunderstorm" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 39:
			imageName = [@"scattered_thunderstorm" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 40:
			imageName = [@"scattered_showers" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 41:
			imageName = [@"rain" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 42:
			imageName = [@"sleet" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 43:
			imageName = @"flurry";
			break;
		case 44:
			imageName = [@"blizzard" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		case 45:
			imageName = [@"severe_thunderstorm" stringByAppendingString:(isDay ? @"_day" : @"_night")];
			break;
		default: break;
	}
	
	if (!imageName) return nil;
	
	NSString* prefixedImageName = [familyPrefix stringByAppendingString:imageName];
	NSString* backgroundImageName = [prefixedImageName stringByAppendingString:@"_Background"];
	NSString* foregroundImageName = [prefixedImageName stringByAppendingString:@"_Foreground"];
	
	UIImage* onePieceImage = [UIImage imageNamed:prefixedImageName inBundle:localizationBundle compatibleWithTraitCollection:UIScreen.mainScreen.traitCollection];
	UIImage* backgroundImage = [UIImage imageNamed:backgroundImageName inBundle:localizationBundle compatibleWithTraitCollection:UIScreen.mainScreen.traitCollection];
	UIImage* foregroundImage = [UIImage imageNamed:foregroundImageName inBundle:localizationBundle compatibleWithTraitCollection:UIScreen.mainScreen.traitCollection];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:onePieceImage twoPieceImageBackground:backgroundImage twoPieceImageForeground:foregroundImage];
	
	NSString* foregroundAccentImageName = [prefixedImageName stringByAppendingString:@"_Accent"];
	UIImage* foregroundAccentImage = [UIImage imageNamed:foregroundAccentImageName inBundle:localizationBundle compatibleWithTraitCollection:UIScreen.mainScreen.traitCollection];
	
	[imageProvider setForegroundAccentImage:foregroundAccentImage];
	
	switch (conditionCode) {
		case 5:
		case 31:
		case 38:
		case 39:
			if (isDay) [imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
			break;
		case 20:
		case 22:
			[imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
			break;
		case 10:
		case 11:
		case 12:
		case 13:
		case 19:
		case 26:
		case 41:
		case 42:
			[imageProvider setTintColor:[%c(NWCColor) conditionsBlueTintColor]];
			break;
		case 33:
		case 35:
			if (isDay) [imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
		case 37:
			[imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
			[imageProvider setForegroundAccentImageColor:UIColor.redColor];
			break;
		case 40:
			if (isDay) [imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
			[imageProvider setForegroundAccentImageColor:[%c(NWCColor) conditionsBlueTintColor]];
			break;
		default: break;
	}
	
	return imageProvider;
}
%end	/// %hook WFWeatherConditions

%hook CLKImageProvider
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
%end	/// %hook CLKImageProvider

%hook NTKStackedImagesComplicationImageView
- (void)layoutSubviews {
	%orig;
	
	[MSHookIvar<UIImageView*>(self, "_foregroundAccentImageView") setTintColor:self.imageProvider.foregroundAccentImageColor];
}
%end	/// %hook NTKStackedImagesComplicationImageView
%end	// %group WeatherComplications



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [%c(LWPreferences) sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/WeatherComplicationsCompanion.bundle/WeatherComplicationsCompanion", RTLD_NOW);
				
				void* weatherLib = dlopen("/usr/lib/LockWatch2Weather.dylib", RTLD_NOW);
				if (weatherLib) {
					%init(WeatherComplications);
				}
				
				%init(SpringBoard);
			}
			
			if ([bundleIdentifier isEqualToString:@"com.apple.healthd"] || [bundleIdentifier isEqualToString:@"com.apple.HealthKit"]) {
				%init(healthd);
			}
		}
	}
}