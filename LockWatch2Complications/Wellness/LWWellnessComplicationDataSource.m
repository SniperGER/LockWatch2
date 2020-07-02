//
// LWWellnessComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 4/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <objc/runtime.h>
#import <HealthKit/HealthKit.h>
#import <NanoTimeKitCompanion/NTKWellnessEntryModel.h>
#import <NanoTimeKitCompanion/NTKWellnessTimelineModel.h>

#import "LWWellnessComplicationDataSource.h"

@implementation LWWellnessComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		[[NTKWellnessTimelineModel sharedModel] addSubscriber:self];
	}
	
	return self;
}

- (void)dealloc {
	[[NTKWellnessTimelineModel sharedModel] removeSubscriber:self];
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_timelineEntryFromModel:(NTKWellnessEntryModel*)model family:(NTKComplicationFamily)family {
	return [model entryForComplicationFamily:family];
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	NTKWellnessEntryModel* entryModel = [[NTKWellnessTimelineModel sharedModel] switcherWelnessEntry];
	CLKComplicationTimelineEntry* timelineEntry = [self _timelineEntryFromModel:entryModel family:self.family];
	
	return [timelineEntry complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NTKWellnessTimelineModel* timelineModel = [NTKWellnessTimelineModel sharedModel];
	[timelineModel getCurrentWellnessEntryWithHandler:^(NTKWellnessEntryModel* entryModel) {
		handler([self _timelineEntryFromModel:entryModel family:self.family]);
	}];
}

- (CLKComplicationTemplate*)lockedTemplate {
	NTKWellnessEntryModel* lockedEntryModel = [NTKWellnessEntryModel lockedEntryModel];
	CLKComplicationTimelineEntry* timelineEntry = [self _timelineEntryFromModel:lockedEntryModel family:self.family];
	
	return [timelineEntry complicationTemplate];
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case NTKComplicationFamilyGraphicCorner:
			return objc_getClass("NTKWellnessRichComplicationCornerView");
		case NTKComplicationFamilyGraphicBezel:
			return objc_getClass("NTKWellnessRichComplicationBezelCircularView");
		case NTKComplicationFamilyGraphicCircular:
			return objc_getClass("NTKWellnessRichComplicationCircularView");
		case NTKComplicationFamilyGraphicRectangular:
			return objc_getClass("NTKWellnessRichComplicationRectangularView");
		default: break;
	}
	
	return nil;
}

#pragma mark - NTKWellnessTimelineModelSubscriber

- (void)wellnessTimeLineModelCurrentEntryModelUpdated:(NTKWellnessEntryModel*)entryModel {
	[self.delegate invalidateEntries];
}

@end