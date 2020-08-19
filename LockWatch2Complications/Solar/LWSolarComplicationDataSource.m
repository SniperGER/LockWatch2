//
// LWSolarComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <CoreLocation/CLLocation.h>

#import "LWSolarComplicationDataSource.h"

@implementation LWSolarComplicationDataSource

+ (BOOL)acceptsComplicationFamily:(CLKComplicationFamily)family forDevice:(CLKDevice*)device {
	return family == CLKComplicationFamilyGraphicBezel || family == CLKComplicationFamilyGraphicCircular;
}

- (void)dealloc {
	[self _cancelLocationUpdates];
}

#pragma mark - Instance Methods

- (void)_cancelLocationUpdates {
	if (_locationToken) {
		[[NTKLocationManager sharedLocationManager] stopLocationUpdatesForToken:_locationToken];
	}
}

- (void)_handleLocation:(CLLocation*)location {
	if (location != _lastLocation) {
		_lastLocation = location;
		
		[self _invalidate];
	}
}

- (void)_invalidate {
	[self.delegate invalidateEntries];
}

- (CLKComplicationTemplate*)_templateFromLocation:(CLLocation*)location useIdealizedTime:(BOOL)useIdealizedTime {
	CLKComplicationTemplate* template = [CLKComplicationTemplate new];
	NSMutableDictionary* metadata = [NSMutableDictionary dictionary];
	
	if (location) {
		[metadata setObject:location forKeyedSubscript:@"NTKSolarComplicationEntryLocationKey"];
	}
	
	[metadata setObject:@(useIdealizedTime) forKeyedSubscript:@"NTKSolarComplicationUseIdealizedTimeKey"];
	[template setMetadata:metadata];
	
	return template;
}

#pragma mark - NTKComplicationDataSource

- (void)becomeActive {
	[super becomeActive];
	[self _cancelLocationUpdates];
	
	_locationToken = [[NTKLocationManager sharedLocationManager] startLocationUpdatesWithIdentifier:@"ntk.NTKSolarComplicationDataSource" handler:^(CLLocation* currentLocation, CLLocation* anyLocation) {
		[self _handleLocation:currentLocation];
	}];
}

- (void)becomeInactive {
	[super becomeInactive];
	[self _cancelLocationUpdates];
}

- (BOOL)alwaysShowIdealizedTemplateInSwitcher {
	return YES;
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return [self _templateFromLocation:_lastLocation useIdealizedTime:YES];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	dispatch_assert_queue(dispatch_get_main_queue());
	
	CLKComplicationTimelineEntry* timelineEntry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:[self _templateFromLocation:_lastLocation useIdealizedTime:NO]];
	handler(timelineEntry);
}

- (void)resume {
	[self _invalidate];
}

- (Class)richComplicationDisplayViewClassForDevice:(CLKDevice*)device {
	switch (self.family) {
		case CLKComplicationFamilyGraphicBezel:
			return NSClassFromString(@"NTKSolarRichComplicationBezelCircularView");
		case CLKComplicationFamilyGraphicCircular:
			return NSClassFromString(@"NTKSolarRichComplicationCircularView");
		default: break;
	}
	
	return nil;
}

- (BOOL)supportsTapAction {
	return NO;
}

@end