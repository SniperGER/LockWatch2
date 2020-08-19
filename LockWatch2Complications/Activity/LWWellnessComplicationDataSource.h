//
// LWWellnessComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/12/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoTimeKitCompanion/NTKWellnessTimelineModelSubscriber-Protocol.h>

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWWellnessComplicationDataSource : LWComplicationDataSourceBase <NTKWellnessTimelineModelSubscriber>

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (CLKComplicationTimelineEntry*)_timelineEntryFromModel:(NTKWellnessEntryModel*)entryModel family:(CLKComplicationFamily)family;

@end

NS_ASSUME_NONNULL_END