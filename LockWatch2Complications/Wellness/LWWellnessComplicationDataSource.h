//
// LWWellnessComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 4/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoTimeKitCompanion/NTKWellnessTimelineModelSubscriber-Protocol.h>

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@class NTKWellnessEntryModel;

@interface LWWellnessComplicationDataSource : LWComplicationDataSourceBase <NTKWellnessTimelineModelSubscriber>

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (CLKComplicationTimelineEntry*)_timelineEntryFromModel:(NTKWellnessEntryModel*)model family:(NTKComplicationFamily)family;

@end

NS_ASSUME_NONNULL_END