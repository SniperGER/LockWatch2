//
// LWAlarmComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@class LWNextAlarm, MTAlarmManager;

@interface LWAlarmComplicationDataSource : LWComplicationDataSourceBase {
	BOOL _listeningForNotifications;
	MTAlarmManager* _alarmManager;
	NTKTimelineEntryModel* _currentAlarmModel;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (id)_activeAlarmEntryForNextAlarm:(LWNextAlarm*)alarm date:(NSDate*)date;
- (NAFuture*)_alarmComplicationFutureWithDate:(NSDate*)date;
- (void)_alarmStoreChangedNotification:(NSNotification*)notification;
- (NTKTimelineEntryModel*)_noAlarmEntry;
- (NTKTimelineEntryModel*)_offAlarmEntry;
- (void)_startObserving;
- (void)_stopObserving;
- (CLKComplicationTimelineEntry*)currentTimelineEntry;
- (NTKTimelineEntryModel*)emptyEntryModel;

@end

NS_ASSUME_NONNULL_END