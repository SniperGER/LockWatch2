//
// LWDateComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <objc/runtime.h>
#import <ClockKit/CLKDate.h>
#import <NanoTimeKitCompanion/NTKDateTimelineEntryModel.h>

#import "LWDateComplicationDataSource.h"

@implementation LWDateComplicationDataSource

+ (BOOL)acceptsComplicationFamily:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	if (family == CLKComplicationFamilyDate) return NO;
	
	return [super acceptsComplicationFamily:family forDevice:device];
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_invalidate) name:UIApplicationSignificantTimeChangeNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_invalidate) name:NSCurrentLocaleDidChangeNotification object:nil];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_currentTimelineEntry {
	NTKDateTimelineEntryModel* entryModel = [NTKDateTimelineEntryModel new];
	[entryModel setEntryDate:[NSCalendar.currentCalendar startOfDayForDate:CLKDate.date]];
	
	NTKComplication* complication = (NTKComplication*)self.complication;
	if (complication.complicationType == NTKComplicationTypeLunarDate) {
		[entryModel setLunar:YES];
	}
	
	return [entryModel entryForComplicationFamily:self.family];
}

- (void)_invalidate {
	[self.delegate invalidateEntries];
}

#pragma mark - NTKComplicationDataSource

- (id)complicationApplicationIdentifier {
	return @"com.apple.mobilecal";
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [[self _currentTimelineEntry] complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	handler([self _currentTimelineEntry]);
}

- (void)getLaunchURLForTimelineEntryDate:(NSDate*)entryDate timeTravelDate:(NSDate*)timeTravelDate withHandler:(void (^)(NSURL* url))handler {
	handler([NSURL URLWithString:@"calshow://"]);
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case CLKComplicationFamilyGraphicCorner:
			return objc_getClass("NTKDateRichComplicationCornerView");
		case CLKComplicationFamilyGraphicBezel:
			return objc_getClass("NTKDateRichComplicationBezelCircularView");
		case CLKComplicationFamilyGraphicCircular:
			return objc_getClass("NTKDateRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

@end