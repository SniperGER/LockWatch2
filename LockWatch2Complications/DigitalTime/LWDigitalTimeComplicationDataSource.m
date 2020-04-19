//
// LWDigitalTimeComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 4/11/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <objc/runtime.h>
#import <ClockKit/CLKComplicationTemplate.h>
#import <ClockKit/CLKComplicationTimelineEntry.h>

#import "LWDigitalTimeComplicationDataSource.h"

@implementation LWDigitalTimeComplicationDataSource

#pragma mark - Instance Methods

- (CLKComplicationTemplate*)_templateWithShouldDisplayIdealizeState:(BOOL)shouldDisplayIdealizeState {
	CLKComplicationTemplate* template = [CLKComplicationTemplate new];
	[template setMetadata:@{
		@"NTKTimerComplicationMetadataShouldDisplayIdealizedStateKey": @(shouldDisplayIdealizeState)
	}];
	
	return template;
}

- (void)resume {
	[self.delegate invalidateSwitcherTemplate];
	[self.delegate invalidateEntries];
}

#pragma mark - NTKComplicationDataSource

- (BOOL)alwaysShowIdealizedTemplateInSwitcher {
	return YES;
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [self _templateWithShouldDisplayIdealizeState:YES];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(id entry))handler {
	CLKComplicationTemplate* template = [self _templateWithShouldDisplayIdealizeState:NO];
	CLKComplicationTimelineEntry* timelineEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template];
	
	handler(timelineEntry);
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case NTKComplicationFamilySignatureBezel:
			return objc_getClass("NTKDigitalTimeRichComplicationBezelView");
		case NTKComplicationFamilySignatureCircular:
			return objc_getClass("NTKDigitalTimeRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

@end