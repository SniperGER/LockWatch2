//
// LWBatteryComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWBatteryComplicationDataSource : LWComplicationDataSourceBase {
	BOOL _listeningForNotifications;
	CGFloat _level;
	UIDeviceBatteryState _state;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (CGFloat)_currentBatteryLevelRounded;
- (CLKComplicationTimelineEntry*)_currentTimelineEntry;
- (void)_handleLocaleChange;
- (void)_levelDidChange:(NSNotification*)notification;
- (void)_powerStateDidChange:(NSNotification*)notification;
- (void)_startObserving;
- (void)_stateDidChange:(NSNotification*)notification;
- (void)_stopObserving;

@end

NS_ASSUME_NONNULL_END