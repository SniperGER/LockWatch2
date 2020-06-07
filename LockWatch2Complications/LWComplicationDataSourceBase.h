//
// LWComplicationDataSourceBase.h
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDate.h>
#import <ClockKit/CLKComplicationTemplate.h>
#import <ClockKit/CLKComplicationTimelineEntry.h>
#import <NanoTimeKitCompanion/NTKComplication.h>
#import <NanoTimeKitCompanion/CLKCComplicationDataSourceDelegate-Protocol.h>
#import <NanoTimeKitCompanion/NTKComplicationDataSource.h>

#import "NTKComplicationFamily.h"
#import "NTKComplicationType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTKComplicationDataSource ()
- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler;
- (void)getSupportedTimeTravelDirectionsWithHandler:(void (^)(long long family))handler;
- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler;
- (void)getTimelineEntriesAfterDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler;
- (void)getTimelineEntriesBeforeDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler;
- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler;
@end

@interface LWComplicationDataSourceBase : NTKComplicationDataSource

@end

NS_ASSUME_NONNULL_END