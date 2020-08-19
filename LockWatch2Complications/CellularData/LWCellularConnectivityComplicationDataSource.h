//
// LWCellularConnectivityComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 7/29/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWCellularConnectivityState) {
/* 0 */	LWCellularConnectivityStateNone,
/* 1 */	LWCellularConnectivityStateIdle,
/* 2 */	LWCellularConnectivityStateEnabled,
/* 3 */	LWCellularConnectivityStateSearching,
/* 4 */	LWCellularConnectivityStateBars0,
/* 5 */	LWCellularConnectivityStateBars1,
/* 6 */	LWCellularConnectivityStateBars2,
/* 7 */	LWCellularConnectivityStateBars3,
/* 8 */	LWCellularConnectivityStateBars4,
};

@class STTelephonySubscriptionInfo;

@interface LWCellularConnectivityComplicationDataSource : LWComplicationDataSourceBase {
	BOOL _pauseAnimations;
	STTelephonySubscriptionInfo* _subscriptionInfo;
	LWCellularConnectivityState _cellularConnectivityState;
	CLKComplicationTimelineEntry* _timelineEntry;
	NSObject<OS_dispatch_queue>* _queue;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (LWCellularConnectivityState)_cellularConnectivityStateForSubscriptionInfo:(STTelephonySubscriptionInfo*)subscriptionInfo;
- (CLKComplicationTimelineEntry*)_currentTimelineEntry;
- (CLKComplicationTimelineEntry*)_defaultTimelineEntry;
- (STTelephonySubscriptionInfo*)_preferredSubscriptionInfo;
- (void)_signalStrengthDidChange;

@end

NS_ASSUME_NONNULL_END