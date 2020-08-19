//
// LWAirQualityDataSource.m
// LockWatch
//
// Created by janikschmidt on 7/2/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWAirQualityDataSource.h"
#import "NWCAirQualityTemplateFormatter+LWAdditions.h"

@implementation LWAirQualityDataSource

+ (id)bundleIdentifier {
	return @"com.apple.weather.airquality";
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!self.currentConditions && !self.switcherTemplate) {
		if (self.family == CLKComplicationFamilyUtilLargeNarrow) return [[NWCAirQualityTemplateFormatter sharedFormatter] switcherTemplateWithFamily:CLKComplicationFamilyUtilitarianLarge];
		return [[NWCAirQualityTemplateFormatter sharedFormatter] switcherTemplateWithFamily:self.family];
	}
	
	return [super currentSwitcherTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NSDate* timelineEntryDate = NSDate.date;
	
	[[NWCAirQualityTemplateFormatter sharedFormatter] formattedTemplateForFamily:self.family
																	   entryDate:timelineEntryDate
																	   isLoading:self.isUpdating
													    withAirQualityConditions:self.currentAirQualityConditions
																	    location:self.city.wfLocation
															     isLocalLocation:self.city.isLocalWeatherCity
																   templateBlock:^(CLKComplicationTemplate* template) {
		CLKComplicationTimelineEntry* timelineEntry = [CLKComplicationTimelineEntry entryWithDate:timelineEntryDate complicationTemplate:template];
		handler(timelineEntry);
	}];
}

@end