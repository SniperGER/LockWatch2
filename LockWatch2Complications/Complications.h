//
// Complications.h
// LockWatch2
//
// Created by janikschmidt on 3/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockComplications/ClockComplications.h>
#import <HealthKit/HealthKit.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>
#import <NanoWeatherComplicationsCompanion/NWCColor.h>
#import <NanoWeatherComplicationsCompanion/WFWeatherConditions-NWMLocalizedWind.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "LWComplicationDataSourceBase.h"
#import "NTKComplicationFamily.h"
#import "NTKComplicationType.h"
#import "Core/LWPreferences.h"

@class SBApplication;

@interface FBSOpenApplicationOptions : NSObject
+ (id)optionsWithDictionary:(id)arg1;
@end

@interface FBSOpenApplicationService : NSObject
+ (instancetype)serviceWithDefaultShellEndpoint;
- (void)openApplication:(id)arg1 withOptions:(id)arg2 completion:(id /* block */)arg4;
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

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)unlockWithRequest:(id)arg1 completion:(id /* block */)arg2;
@end

@interface SBLockScreenUnlockRequest : NSObject
@property(nonatomic) BOOL forceAlertAuthenticationUI;
@property(nonatomic) BOOL wantsBiometricPresentation;
@property(retain, nonatomic) SBApplication *destinationApplication;
@property(nonatomic) int intent;
@property(nonatomic) int source;
@property(copy, nonatomic) NSString *name;
@end