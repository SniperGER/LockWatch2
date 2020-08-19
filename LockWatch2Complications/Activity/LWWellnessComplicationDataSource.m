//
// LWWellnessComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/12/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

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

- (CLKComplicationTimelineEntry*)_timelineEntryFromModel:(NTKWellnessEntryModel*)entryModel family:(CLKComplicationFamily)family {
	return [entryModel entryForComplicationFamily:family];
}

#pragma mark - NTKComplicationDataSource

- (id)complicationApplicationIdentifier {
	return @"com.apple.Fitness";
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	NTKWellnessEntryModel* entryModel = [[NTKWellnessTimelineModel sharedModel] switcherWelnessEntry];
	
	if (self.family == CLKComplicationFamilyUtilLargeNarrow) return [NTKWellnessEntryModel largeUtility:entryModel];
	
	CLKComplicationTimelineEntry* timelineEntry = [self _timelineEntryFromModel:entryModel family:self.family];
	return [timelineEntry complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NTKWellnessTimelineModel* timelineModel = [NTKWellnessTimelineModel sharedModel];
	[timelineModel getCurrentWellnessEntryWithHandler:^(NTKWellnessEntryModel* entryModel) {
		handler([self _timelineEntryFromModel:entryModel family:self.family]);
	}];
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler([NSURL URLWithString:@"activitytoday://"]);
}

- (CLKComplicationTemplate*)lockedTemplate {
	NTKWellnessEntryModel* lockedEntryModel = [NTKWellnessEntryModel lockedEntryModel];
	CLKComplicationTimelineEntry* timelineEntry = [self _timelineEntryFromModel:lockedEntryModel family:self.family];
	
	return [timelineEntry complicationTemplate];
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case CLKComplicationFamilyGraphicCorner:
			return NSClassFromString(@"NTKWellnessRichComplicationCornerView");
		case CLKComplicationFamilyGraphicBezel:
			return NSClassFromString(@"NTKWellnessRichComplicationBezelCircularView");
		case CLKComplicationFamilyGraphicCircular:
			return NSClassFromString(@"NTKWellnessRichComplicationCircularView");
		case CLKComplicationFamilyGraphicRectangular:
			return NSClassFromString(@"NTKWellnessRichComplicationRectangularView");
		default: break;
	}
	
	return nil;
}

#pragma mark - NTKWellnessTimelineModelSubscriber

- (void)wellnessTimeLineModelCurrentEntryModelUpdated:(NTKWellnessEntryModel*)entryModel {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate appendEntries:@[ [self _timelineEntryFromModel:entryModel family:self.family] ]];
	});
}

@end