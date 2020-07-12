//
// LWWorldClockComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 4/10/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <objc/runtime.h>
#import <MobileTimer/WorldClockCity.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "LWWorldClockComplicationDataSource.h"

@implementation LWWorldClockComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		[self _startObserving];
	}
	
	return self;
}

- (void)dealloc {
	[self _stopObserving];
}

#pragma mark - Instance Methods

- (WorldClockCity*)_city {
	return [(NTKWorldClockComplication*)self.complication city];
}

- (NTKWorldClockTimelineEntryModel*)_currentEntryModel {
	NTKWorldClockTimelineEntryModel* entryModel = [NTKWorldClockTimelineEntryModel new];
	[entryModel setEntryDate:[NSDate date]];
	[entryModel setShowIdealizedTime:NO];
	[entryModel setCity:[self _city]];
	
	return entryModel;
}

- (CLKComplicationTimelineEntry*)_currentTimelineEntry {
	NTKWorldClockTimelineEntryModel* model = [self _currentEntryModel];
	
	return [model entryForComplicationFamily:self.family];
}

- (void)_handleAbbreviationStoreChange:(NSNotification*)notification {
	[self.delegate invalidateEntries];
}

- (void)_handleLocaleChange:(NSNotification*)notification {
	[self.delegate invalidateEntries];
}

- (void)_handleTimeZoneChange:(NSNotification*)notification {
	[self.delegate invalidateEntries];
}

- (void)_startObserving {
	if (!_listeningForNotifications) {
		_listeningForNotifications = YES;
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_handleAbbreviationStoreChange:) name:@"NTKCustomWorldCityAbbreviationsChangedNotification" object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_handleLocaleChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_handleTimeZoneChange:) name:NSSystemTimeZoneDidChangeNotification object:nil];
		
		[self.delegate invalidateEntries];
	}
}

- (void)_stopObserving {
	_listeningForNotifications = NO;
	
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)pause {
	[self _stopObserving];
}

- (void)resume {
	[self _startObserving];
}

#pragma mark - NTKComplicationDataSource

- (BOOL)alwaysShowIdealizedTemplateInSwitcher {
	return YES;
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	NTKWorldClockTimelineEntryModel* entryModel = [self _currentEntryModel];
	[entryModel setShowIdealizedTime:YES];
	
	return [[entryModel entryForComplicationFamily:self.family] complicationTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	handler([self _currentTimelineEntry]);
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case NTKComplicationFamilyGraphicBezel:
			return objc_getClass("NTKWorldClockRichComplicationBezelCircularView");
		case NTKComplicationFamilyGraphicCircular:
			return objc_getClass("NTKWorldClockRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

@end