//
// Complications.h
// LockWatch2
//
// Created by janikschmidt on 3/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#include <substrate.h>

#import <ClockKit/ClockKit.h>
#import <HealthKit/HealthKit.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>
#import <NanoWeatherComplicationsCompanion/NWCColor.h>
#import <NanoWeatherComplicationsCompanion/WFWeatherConditions-NWMLocalizedWind.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "LWComplicationDataSourceBase.h"
#import "LWComplicationLocationManager.h"

#import "Core/LWPreferences.h"

@interface CompassRichRectangularDialView : UIView
// %property
@property (nonatomic, strong) CAGradientLayer* gradientMask;
@end

@interface _HKCurrentActivitySummaryQuery : HKQuery
- (id)initWithUpdateHandler:(/*^block*/id)arg1;
- (void)_setCollectionIntervals:(NSDictionary*)arg1;
@end

@interface HKCurrentActivityCacheQuery : HKQuery
- (id)initWithStatisticsIntervalComponents:(id)arg1 updateHandler:(id /* block */)arg2;
@end

@interface HKCurrentActivityCacheQueryResult : NSObject
@end

@interface HDActivityCacheManager : NSObject
- (id)initWithProfile:(id)arg1;
@end