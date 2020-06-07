//
// LWDateComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWDateComplicationDataSource : LWComplicationDataSourceBase

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (CLKComplicationTimelineEntry*)_currentTimelineEntry;
- (void)_invalidate;

@end

NS_ASSUME_NONNULL_END