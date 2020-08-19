//
// LWTimerComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@class MTTimerManager, NTKTimerTimelineEntry;

@interface LWTimerComplicationDataSource : LWComplicationDataSourceBase {
	NSNumber* _timerToken;
	NTKTimerTimelineEntry* _currentTimerEntry;
	BOOL _listeningForNotifications;
	MTTimerManager* _timerManager;
}

@end

NS_ASSUME_NONNULL_END