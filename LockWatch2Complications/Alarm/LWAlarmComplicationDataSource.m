//
// LWAlarmComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <MobileTimer/MTAlarmManager.h>
#import <NetAppsUtilities/NAFuture.h>
#import <NetAppsUtilities/NAScheduler.h>

#import "LWAlarmComplicationDataSource.h"
#import "LWNextAlarm.h"

@implementation LWAlarmComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_alarmManager = [NSClassFromString(@"MTAlarmManager") new];
		[self _startObserving];
	}
	
	return self;
}

- (void)dealloc {
	[self _stopObserving];
}

#pragma mark - Instance Methods

- (id)_activeAlarmEntryForNextAlarm:(LWNextAlarm*)alarm date:(NSDate*)date {
	NTKAlarmTimelineEntry* timelineEntry = [NTKAlarmTimelineEntry new];
	[timelineEntry setEntryDate:[NSDate date]];
	
	NSDateInterval* interval = [[NSDateInterval alloc] initWithStartDate:date endDate:[[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0]];
	if ([interval containsDate:alarm.trigger.triggerDate]) {
		if ([alarm.alarm isSnoozed]) {
			[timelineEntry setSnoozeDate:alarm.trigger.triggerDate];
			[timelineEntry setFireDate:alarm.trigger.triggerDate];
			[timelineEntry setEntryType:5];
		} else {
			[timelineEntry setFireDate:alarm.trigger.triggerDate];
			[timelineEntry setEntryType:4];
		}
	} else {
		[timelineEntry setEntryType:3];
	}
	
	[timelineEntry setAlarmLabel:alarm.alarm.title];
	
	return timelineEntry;
}

- (NAFuture*)_alarmComplicationFutureWithDate:(NSDate*)date {
	NAFuture* alarms = [_alarmManager alarmsIncludingSleepAlarm:YES];
	
	/// TODO: Flat map that shit
	
	return [NSClassFromString(@"NAFuture") combineAllFutures:@[ alarms ] ignoringErrors:NO scheduler:[NSClassFromString(@"NAScheduler") globalAsyncScheduler]];
}

- (void)_alarmStoreChangedNotification:(NSNotification*)notification {
	[self.delegate invalidateEntries];
}

- (NTKTimelineEntryModel*)_noAlarmEntry {
	NTKAlarmTimelineEntry* timelineEntry = [NTKAlarmTimelineEntry new];
	[timelineEntry setEntryDate:[NSDate date]];
	[timelineEntry setEntryType:1];
	
	return timelineEntry;
}

- (NTKTimelineEntryModel*)_offAlarmEntry {
	NTKAlarmTimelineEntry* timelineEntry = [NTKAlarmTimelineEntry new];
	[timelineEntry setEntryDate:[NSDate date]];
	[timelineEntry setEntryType:2];
	
	return timelineEntry;
}

- (void)_startObserving {
	if (!_listeningForNotifications) {
		_listeningForNotifications = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_alarmStoreChangedNotification:) name:@"MTAlarmManagerAlarmsChanged" object:_alarmManager];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_alarmStoreChangedNotification:) name:@"MTAlarmManagerStateReset" object:_alarmManager];
		
		[self.delegate invalidateEntries];
	}
}

- (void)_stopObserving {
	_listeningForNotifications = NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CLKComplicationTimelineEntry*)currentTimelineEntry {
	if (_currentAlarmModel) {
		return [_currentAlarmModel entryForComplicationFamily:self.family];
	}
	
	return [[self emptyEntryModel] entryForComplicationFamily:self.family];
}

- (NTKTimelineEntryModel*)emptyEntryModel {
	return [self _noAlarmEntry];
}

#pragma mark - NTKComplicationDataSource

- (id)complicationApplicationIdentifier {
	return @"com.apple.mobiletimer";
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [[self currentTimelineEntry] complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NAFuture* complicationFuture = [self _alarmComplicationFutureWithDate:[NSDate date]];
	[complicationFuture addCompletionBlock:^(NAFuture* future, NSError* error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			/// TODO
		});
	}];
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler([NSURL URLWithString:@"clock-alarm://"]);
}

- (void)pause {
	[self _stopObserving];
}

- (void)resume {
	[self _startObserving];
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case CLKComplicationFamilyGraphicBezel:
			return NSClassFromString(@"NTKAlarmRichComplicationBezelCircularView");
		case CLKComplicationFamilyGraphicCircular:
			return NSClassFromString(@"NTKAlarmRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

@end