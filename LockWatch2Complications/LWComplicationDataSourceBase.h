//
// LWComplicationDataSourceBase.h
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "CLKComplicationFamily.h"
#import "CLKComplicationTimeTravelDirections.h"
#import "NTKComplicationType.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWComplicationDataSourceBase : NTKComplicationDataSource

+ (BOOL)acceptsComplicationType:(NSUInteger)type forDevice:(CLKDevice*)device;
+ (BOOL)acceptsComplicationFamily:(CLKComplicationFamily)family forDevice:(CLKDevice*)device;
+ (NSString*)complicationApplicationIdentifierForComplicationType:(NTKComplicationType)complicationType;
+ (Class)dataSourceClassForBundleComplication:(NTKBundleComplication*)bundleComplication;
+ (Class)dataSourceClassForComplicationType:(NTKComplicationType)complicationType family:(CLKComplicationFamily)family forDevice:(CLKDevice*)device;
- (id)complicationApplicationIdentifier;
- (CLKComplicationTemplate*)currentSwitcherTemplate;
- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler;
- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler;
- (void)getSupportedTimeTravelDirectionsWithHandler:(void (^)(CLKComplicationTimeTravelDirections directions))handler;
- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler;
- (void)getTimelineEntriesAfterDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler;
- (void)getTimelineEntriesBeforeDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler;
- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler;

@end

NS_ASSUME_NONNULL_END