//
// Complications.xm
// LockWatch2
//
// Created by janikschmidt on 3/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "Complications.h"

void LWLaunchApplication(NSString* bundleIdentifier, NSURL* url = nil) {
	SBApplication* destinationApplication = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
		
	if (!destinationApplication) return;
	
	SBLockScreenUnlockRequest* request = [%c(SBLockScreenUnlockRequest) new];
	[request setSource:17];
	[request setIntent:3];
	[request setName:[NSString stringWithFormat:@"SBWorkspaceRequest: Open \"%@\"", bundleIdentifier]];
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
				
				[appService openApplication:bundleIdentifier withOptions:openOptions completion:nil];
			} else {
				[appService openApplication:bundleIdentifier withOptions:nil completion:nil];
			}
		}
	}];
}

%group SpringBoard
%hook NTKComplicationDataSource
+ (Class)dataSourceClassForComplicationType:(NTKComplicationType)type family:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	LWComplicationContentType complicationContentType = [[%c(LWPreferences) sharedInstance] complicationContent];
	switch (complicationContentType) {
		case LWComplicationContentTypeNone: return nil;
		case LWComplicationContentTypeTemplate: return %orig;
		default: break;
	}
	
	Class dataSourceClass = [LWComplicationDataSourceBase dataSourceClassForComplicationType:type family:family forDevice:device];
	
	BOOL acceptsComplicationFamily = YES;
	if (dataSourceClass) {
		acceptsComplicationFamily = [dataSourceClass acceptsComplicationFamily:family forDevice:device];
	}
	
	if (complicationContentType == LWComplicationContentTypeDefault) {
		if (dataSourceClass && acceptsComplicationFamily) return dataSourceClass;
		return %orig;
	} else if (!acceptsComplicationFamily) return nil;
	
	return dataSourceClass;
}
%end	/// %hook NTKComplicationDataSource

%hook NTKBundleComplicationManager
- (Class)dataSourceClassForBundleComplication:(NTKBundleComplication*)bundleComplication {
	if (![bundleComplication isKindOfClass:%c(NTKBundleComplication)]) return %orig;
	
	LWComplicationContentType complicationContentType = [[%c(LWPreferences) sharedInstance] complicationContent];
	switch (complicationContentType) {
		case LWComplicationContentTypeNone: return nil;
		case LWComplicationContentTypeTemplate: return %orig;
		default: break;
	}
	
	Class dataSourceClass = [LWComplicationDataSourceBase dataSourceClassForBundleComplication:bundleComplication];
	
	if (complicationContentType == LWComplicationContentTypeDefault) {
		if (dataSourceClass) return dataSourceClass;
		return %orig;
	}
	
	return dataSourceClass;
}
%end	/// %hook NTKBundleComplicationManager

%hook NTKCompanionComplicationDataSource
- (NSString*)complicationApplicationIdentifier {
	NSString* applicationIdentifier = [LWComplicationDataSourceBase complicationApplicationIdentifierForComplicationType:[(NTKComplication*)self.complication complicationType]];
	
	if (applicationIdentifier) return applicationIdentifier;
	return %orig;
}
%end	/// %hook NTKCompanionComplicationDataSource

%hook NTKLauncherComplicationDataSource
- (NSString*)_complicationApplicationIdentifier {
	NSString* applicationIdentifier = [LWComplicationDataSourceBase complicationApplicationIdentifierForComplicationType:[(NTKComplication*)self.complication complicationType]];
	
	if (applicationIdentifier) return applicationIdentifier;
	return %orig;
}
%end	/// %hook NTKLauncherComplicationDataSource

// - Complication Fixes

%hook CKMessagesComplicationDataSource
- (id)templateForFamily:(long long)arg1 unreadCount:(unsigned long long)arg2 locked:(BOOL)arg3 privacy:(BOOL)arg4 {
	return %orig(arg1, arg2, [[(SpringBoard*)[UIApplication sharedApplication] pluginUserAgent] deviceIsPasscodeLocked], arg4);
}
%end	/// %hook CKMessagesComplicationDataSource

%hook CLKImageProvider
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
%end	/// %hook CLKImageProvider

%hook CompassRichRectangularDialView
%property (nonatomic, strong) CAGradientLayer* gradientMask;
- (void)layoutSubviews {
	%orig;
	
	[MSHookIvar<CAGradientLayer*>(self, "_leftGradient") removeFromSuperlayer];
	[MSHookIvar<CAGradientLayer*>(self, "_rightGradient") removeFromSuperlayer];
}
%end	/// %hook CompassRichRectangularDialView

%hook NTKAlarmTimelineEntry
- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [self _newLargeUtilityTemplate];
	return %orig;
}
%end	/// %hook NTKAlarmTimelineEntry

%hook NTKBatteryTimelineEntryModel
- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [self _newUtilitarianLargeTemplate];
	return %orig;
}
%end	/// %hook NTKBatteryTimelineEntryModel

%hook NTKBatteryUtilities
+ (UIColor*)colorForLevel:(CGFloat)arg1 andState:(NSInteger)arg2 {
	if (NSProcessInfo.processInfo.isLowPowerModeEnabled) return UIColor.systemYellowColor;
	
	return %orig;
}
%end	/// %hook NTKBatteryUtilities

%hook NTKDateTimelineEntryModel
- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [self _newLargeUtilitarianTemplate];
	return %orig;
}
%end	/// %hook NTKDateTimelineEntryModel

%hook NTKLocalTimelineComplicationController
- (void)performTapAction {
	CLKCComplicationDataSource* dataSource = MSHookIvar<CLKCComplicationDataSource*>(self, "_dataSource");
	if (!dataSource || ![dataSource supportsTapAction]) return;
	
	[dataSource getLaunchURLForTimelineEntryDate:nil timeTravelDate:nil withHandler:^(NSURL* url) {
		LWLaunchApplication(dataSource.complicationApplicationIdentifier, url);
	}];
}
%end	/// %hook NTKLocalTimelineComplicationController

%hook NTKLocationManager
+ (id)sharedLocationManager {
    static LWComplicationLocationManager* sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[LWComplicationLocationManager alloc] init];
    });

    return sharedLocationManager;
}
%end	/// %hook NTKLocationManager

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

%hook NTKStackedImagesComplicationImageView
- (void)layoutSubviews {
	%orig;
	
	[MSHookIvar<UIImageView*>(self, "_foregroundAccentImageView") setTintColor:self.imageProvider.foregroundAccentImageColor];
}
%end	/// %hook NTKStackedImagesComplicationImageView

%hook NTKTimelineDataOperation
- (void)start {
	if ([MSHookIvar<NSObject*>(self, "_localDataSource") isKindOfClass:%c(LWComplicationDataSourceBase)]) {
		%orig;
	}
	
	return;
}
%end	/// %hook NTKTimelineDataOperation

%hook NTKTimerTimelineEntry
- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [self _newLargeFlatUtilityTemplate];
	return %orig;
}
%end	/// %hook NTKTimerTimelineEntry

%hook NTKVictoryAppLauncher
+ (void)attemptLaunchWithDelegate:(id)arg1 {
	LWLaunchApplication(@"com.nike.nikeplus-gps");
}
%end

%hook NTKWellnessEntryModel
- (BOOL)userHasDoneActivitySetup {
	return YES;
}

- (BOOL)databaseLoading {
	return NO;
}

- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [NTKWellnessEntryModel largeUtility:self];
	return %orig;
}
%end	/// %hook NTKWellnessEntryModel

%hook NTKWellnessTimelineModel
- (void)_queue_startQueries {
	MSHookIvar<NSDate*>(self, "_currentDate") = [NSDate date];
	
	_HKCurrentActivitySummaryQuery* summaryQuery = [[%c(_HKCurrentActivitySummaryQuery) alloc] initWithUpdateHandler:^(_HKCurrentActivitySummaryQuery* query, HKActivitySummary* activitySummary, NSError* error) {
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
	
	HKCurrentActivityCacheQuery* cacheQuery = [[%c(HKCurrentActivityCacheQuery) alloc] initWithStatisticsIntervalComponents:dateComponents updateHandler:^(HKCurrentActivityCacheQuery* query, HKCurrentActivityCacheQueryResult* result, NSError* error) {
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

%hook NTKWorldClockTimelineEntryModel
- (id)templateForComplicationFamily:(CLKComplicationFamily)arg1 {
	if (arg1 == CLKComplicationFamilyUtilLargeNarrow) return [self _newLargeUtilityTemplate];
	return %orig;
}
%end	/// %hook NTKWorldClockTimelineEntryModel

%hook STTelephonyStateProvider
- (void)_setSignalStrengthBars:(NSUInteger)arg1 maxBars:(NSUInteger)arg2 inSubscriptionContext:(id)arg3 {
	%orig;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SBCellularSignalStrengthChangedNotification" object:nil userInfo:nil];
}
%end
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
%end	/// %hook HDPrimaryProfile

%hook HDReadAuthorizationStatus
- (long long)authorizationStatus {
	return 1;
}
%end	/// %hook HDReadAuthorizationStatus
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
			[imageProvider setTintColor:isDay ? [%c(NWCColor) conditionsYellowTintColor] : nil];
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
			[imageProvider setTintColor:isDay ? [%c(NWCColor) conditionsYellowTintColor] : nil];
			break;
		case 37:
			[imageProvider setTintColor:[%c(NWCColor) conditionsYellowTintColor]];
			[imageProvider setForegroundAccentImageColor:UIColor.redColor];
			break;
		case 40:
			[imageProvider setTintColor:isDay ? [%c(NWCColor) conditionsYellowTintColor] : nil];
			[imageProvider setForegroundAccentImageColor:[%c(NWCColor) conditionsBlueTintColor]];
			break;
		default: break;
	}
	
	return imageProvider;
}
%end	/// %hook WFWeatherConditions
%end	// %group WeatherComplications


#if !TARGET_OS_SIMULATOR
extern "C" BOOL NTKIsSystemAppRestrictedOrRemoved(NSString* identifier);

MSHook(BOOL, NTKIsSystemAppRestrictedOrRemoved, NSString* key) {
	return NO;
}
#endif



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [%c(LWPreferences) sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if (IN_SPRINGBOARD) {
				// Preload complication bundles so we can hook into them
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/MessagesComplication.bundle/MessagesComplication", RTLD_NOW);
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/NanoCompassComplications.bundle/NanoCompassComplications", RTLD_NOW);
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/NTKCellularConnectivityCompanionComplicationBundle.bundle/NTKCellularConnectivityCompanionComplicationBundle", RTLD_NOW);
				dlopen("/System/Library/NanoTimeKit/ComplicationBundles/WeatherComplicationsCompanion.bundle/WeatherComplicationsCompanion", RTLD_NOW);
				
				void* weatherLib = dlopen("/usr/lib/LockWatch2Weather.dylib", RTLD_NOW);
				if (weatherLib) {
					%init(WeatherComplications);
				}
				
				%init(SpringBoard);
				
#if !TARGET_OS_SIMULATOR
				MSHookFunction(NTKIsSystemAppRestrictedOrRemoved, MSHake(NTKIsSystemAppRestrictedOrRemoved));
#endif
			}
			
			if (IN_BUNDLE(@"com.apple.healthd")) {
				%init(healthd);
			}
		}
	}
}