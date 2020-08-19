//
// LWTimerComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <MobileTimer/MTTimer.h>
#import <MobileTimer/MTTimerManager.h>
#import <NetAppsUtilities/NAFuture.h>

#import "LWTimerComplicationDataSource.h"

extern NSObject* NAEmptyResult();

@implementation LWTimerComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_timerManager = [NSClassFromString(@"MTTimerManager") new];
		
		[self _startObserving];
	}
	
	return self;
}

- (void)dealloc {
	[self _stopObserving];
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_currentTimelineEntry {
	if (_currentTimerEntry) {
		return [_currentTimerEntry entryForComplicationFamily:self.family];
	}
	
	return [[self _unknownEntry] entryForComplicationFamily:self.family];
}

- (void)_handleLocaleChange {
	[self.delegate invalidateEntries];
}

- (void)_handleTimeFormatChange {
	[self.delegate invalidateEntries];
}

- (void)_startObserving {
	if (!_listeningForNotifications) {
		_listeningForNotifications = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timerDidChange:) name:@"MTTimerManagerTimersUpdated" object:_timerManager];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_timerDidChange:) name:@"MTTimerManagerStateReset" object:_timerManager];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleLocaleChange) name:NSCurrentLocaleDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleTimeFormatChange) name:@"CLKFormatTimeIntervalCacheInvalidateNotification" object:nil];
		
		[self.delegate invalidateEntries];
	}
}

- (void)_stopObserving {
	_listeningForNotifications = NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_timerDidChange:(NSNotification*)notification {
	[self.delegate invalidateEntries];
}

- (NTKTimelineEntryModel*)_unknownEntry {
	NTKTimerTimelineEntry* timelineEntry = [NTKTimerTimelineEntry new];
	[timelineEntry setEntryDate:[NSDate date]];
	[timelineEntry setState:0];
	
	return timelineEntry;
}

#pragma mark - NTKComplicationDataSource

- (id)complicationApplicationIdentifier {
	return @"com.apple.mobiletimer";
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [[self _currentTimelineEntry] complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NAFuture* complicationFuture = [_timerManager currentTimer];
	[complicationFuture addCompletionBlock:^(MTTimer* timer, NSError* error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!timer) {
				handler(nil);
				return;
			}
			
			if (error || [timer isEqual:NAEmptyResult()]) {
				handler([[self _unknownEntry] entryForComplicationFamily:self.family]);
				return;
			}
			
			NTKTimerTimelineEntry* timelineEntry = [NTKTimerTimelineEntry new];
			[timelineEntry setEntryDate:[NSDate date]];
			[timelineEntry setRemainingTime:[timer remainingTime]];
			[timelineEntry setState:[timer state]];
			[timelineEntry setCountdownDuration:[timer duration]];
			
			_currentTimerEntry = timelineEntry;
			
			handler([timelineEntry entryForComplicationFamily:self.family]);
		});
	}];
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler([NSURL URLWithString:@"clock-timer://"]);
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
		case CLKComplicationFamilyGraphicRectangular:
			return NSClassFromString(@"NTKRichComplicationRectangularTextGaugeView");
		default: break;
	}
	
	return nil;
}

@end