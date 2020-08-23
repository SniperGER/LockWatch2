//
// LWCellularConnectivityComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 7/29/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <SystemStatusServer/SystemStatusServer.h>

#import "LWCellularConnectivityComplicationDataSource.h"

@interface NTKCellularConnectivityTimelineEntryModel : NTKTimelineEntryModel
- (void)setCellularConnectivityState:(NSInteger)arg1;
@end

@interface SBAirplaneModeController
+ (instancetype)sharedInstance;
- (BOOL)isInAirplaneMode;
@end

@interface SBTelephonyManager
+ (instancetype)sharedTelephonyManager;
- (NSInteger)_dataPreferredSubscriptionSlotIfSIMPresent;
- (STTelephonySubscriptionInfo*)_primarySubscriptionInfo;
- (STTelephonySubscriptionInfo*)_secondarySubscriptionInfo;
@end



@implementation LWCellularConnectivityComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_pauseAnimations = NO;
		_cellularConnectivityState = LWCellularConnectivityStateNone;
		
		_queue = dispatch_queue_create("com.apple.NanoTimeKit.NTKCellularConnectivityComplicationDataSource", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0));
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_signalStrengthDidChange) name:@"SBCellularSignalStrengthChangedNotification" object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_signalStrengthDidChange) name:@"SBAirplaneModeControllerAirplaneModeDidChangeNotification" object:nil];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (LWCellularConnectivityState)_cellularConnectivityStateForSubscriptionInfo:(STTelephonySubscriptionInfo*)subscriptionInfo {
	if ([[NSClassFromString(@"SBAirplaneModeController") sharedInstance] isInAirplaneMode]) return LWCellularConnectivityStateBars0;
	if (!subscriptionInfo) return LWCellularConnectivityStateNone;
	
	switch ([subscriptionInfo registrationStatus]) {
		case 1:
			return LWCellularConnectivityStateSearching;
		case 2:
			return LWCellularConnectivityStateBars0 + [subscriptionInfo signalStrengthBars];
		case 3:
			return LWCellularConnectivityStateBars0;
		default: break;
	}
	
	return LWCellularConnectivityStateNone;
}

- (CLKComplicationTimelineEntry*)_currentTimelineEntry {
	NTKCellularConnectivityTimelineEntryModel* timelineEntryModel = [NSClassFromString(@"NTKCellularConnectivityTimelineEntryModel") new];
	[timelineEntryModel setEntryDate:[CLKDate complicationDate]];
	[timelineEntryModel setCellularConnectivityState:[self _cellularConnectivityStateForSubscriptionInfo:_subscriptionInfo]];
	
	return [timelineEntryModel entryForComplicationFamily:self.family];
}

- (CLKComplicationTimelineEntry*)_defaultTimelineEntry {
	NTKCellularConnectivityTimelineEntryModel* timelineEntryModel = [NSClassFromString(@"NTKCellularConnectivityTimelineEntryModel") new];
	[timelineEntryModel setEntryDate:[CLKDate complicationDate]];
	[timelineEntryModel setCellularConnectivityState:0];
	
	return [timelineEntryModel entryForComplicationFamily:self.family];
}

- (STTelephonySubscriptionInfo*)_preferredSubscriptionInfo {
	SBTelephonyManager* telephonyManager = [NSClassFromString(@"SBTelephonyManager") sharedTelephonyManager];
	NSInteger preferredSlot = [telephonyManager _dataPreferredSubscriptionSlotIfSIMPresent];
	
	switch (preferredSlot) {
		case 1: return [telephonyManager _primarySubscriptionInfo];
		case 2: return [telephonyManager _secondarySubscriptionInfo];
		default: return nil;
	}
}

- (void)_signalStrengthDidChange {
	dispatch_async(_queue, ^{
		_subscriptionInfo = [self _preferredSubscriptionInfo];
		_timelineEntry = [self _currentTimelineEntry];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate invalidateEntriesWithTritiumUpdatePriority:1];
			[self.delegate invalidateSwitcherTemplate];
		});
	});
}

#pragma mark - NTKComplicationDataSource

- (BOOL)alwaysShowIdealizedTemplateInSwitcher {
	return YES;
}

- (void)becomeActive {
	[self _signalStrengthDidChange];
}

- (id)complicationApplicationIdentifier {
	return @"com.apple.Preferences";
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (_timelineEntry) {
		return [_timelineEntry complicationTemplate];
	} else {
		return [[self _defaultTimelineEntry] complicationTemplate];
	}
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	if (_timelineEntry) {
		handler(_timelineEntry);
	} else {
		handler([self _defaultTimelineEntry]);
	}
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler([NSURL URLWithString:@"prefs:root=MOBILE_DATA_SETTINGS_ID"]);
}

- (void)resume {
	[self _signalStrengthDidChange];
}

@end