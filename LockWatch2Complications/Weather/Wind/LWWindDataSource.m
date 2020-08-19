//
// LWWindDataSource.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWWindDataSource.h"
#import "NWCWindTemplateFormatter+LWAdditions.h"

@implementation LWWindDataSource

+ (id)bundleIdentifier {
	return @"com.apple.weather.wind";
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!self.currentConditions && !self.switcherTemplate) {
		if (self.family == CLKComplicationFamilyUtilLargeNarrow) return [[NWCWindTemplateFormatter sharedFormatter] switcherTemplateWithFamily:CLKComplicationFamilyUtilitarianLarge];
		return [[NWCWindTemplateFormatter sharedFormatter] switcherTemplateWithFamily:self.family];
	}
	
	return [super currentSwitcherTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NSDate* timelineEntryDate = NSDate.date;
	
	[[NWCWindTemplateFormatter sharedFormatter] formattedTemplateForFamily:self.family
																	entryDate:timelineEntryDate
																	isLoading:self.isUpdating
															   withConditions:self.currentConditions
													dailyForecastedConditions:self.currentDayForecasts
												   hourlyForecastedConditions:self.currentHourlyForecasts
																	 location:self.city.wfLocation
															  isLocalLocation:self.city.isLocalWeatherCity
																templateBlock:^(CLKComplicationTemplate* template) {
		CLKComplicationTimelineEntry* timelineEntry = [CLKComplicationTimelineEntry entryWithDate:timelineEntryDate complicationTemplate:template];
		handler(timelineEntry);
	}];
}

@end