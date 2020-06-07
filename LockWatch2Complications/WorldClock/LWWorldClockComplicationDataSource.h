//
// LWWorldClockComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 4/10/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWWorldClockComplicationDataSource : LWComplicationDataSourceBase {
	BOOL _listeningForNotifications;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (WorldClockCity*)_city;
- (NTKWorldClockTimelineEntryModel*)_currentEntryModel;
- (CLKComplicationTimelineEntry*)_currentTimelineEntry;
- (void)_handleAbbreviationStoreChange:(NSNotification*)notification;
- (void)_handleLocaleChange:(NSNotification*)notification;
- (void)_handleTimeZoneChange:(NSNotification*)notification;
- (void)_startObserving;
- (void)_stopObserving;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END