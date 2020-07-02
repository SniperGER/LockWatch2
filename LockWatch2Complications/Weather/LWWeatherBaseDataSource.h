//
// LWWeatherBaseDataSource.h
// LockWatch
//
// Created by janikschmidt on 6/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Weather/Weather.h>

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTemplate, WFAirQualityConditions, WFWeatherConditions;

@interface LWWeatherBaseDataSource : LWComplicationDataSourceBase {
	time_t _updateTimestamp;
	NSTimer* _updateTimer;
}

@property (nonatomic) City* city;
@property (nonatomic) WFAirQualityConditions* currentAirQualityConditions;
@property (nonatomic) WFWeatherConditions* currentConditions;
@property (nonatomic) NSArray<WFWeatherConditions*>* currentDayForecasts;
@property (nonatomic) NSArray<WFWeatherConditions*>* currentHourlyForecasts;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, retain) CLKComplicationTemplate* switcherTemplate;

+ (NSString*)appIdentifier;
+ (NSString*)complicationLocalizationKey;
+ (CGFloat)updateInterval;
- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (void)__discardData;
- (City*)_activeCity;
- (void)_invalidate;
- (void)_localeChanged:(NSNotification*)notification;
- (NSDateComponents*)_nwkDateComponentsForDate:(NSDate*)date;
- (void)_startUpdateTimerIfNeeded;
- (void)_stopUpdateTimer;
- (void)_updateIfNeeded;
- (void)becomeActive;
- (void)becomeInactive;
- (CLKComplicationTemplate*)currentSwitcherTemplate;
- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler;
- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END