//
// LWWeatherDataSource.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWWeatherDataSource.h"
#import "NWCWeatherTemplateFormatter+LWAdditions.h"

@implementation LWWeatherDataSource

+ (id)bundleIdentifier {
	return @"com.apple.weather";
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!self.currentConditions && !self.switcherTemplate) {
		if (self.family == CLKComplicationFamilyUtilLargeNarrow) return [[NWCWeatherTemplateFormatter sharedFormatter] switcherTemplateWithFamily:CLKComplicationFamilyUtilitarianLarge];
		return [[NWCWeatherTemplateFormatter sharedFormatter] switcherTemplateWithFamily:self.family];
	}
	
	return [super currentSwitcherTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NSDate* timelineEntryDate = NSDate.date;
	
	[[NWCWeatherTemplateFormatter sharedFormatter] formattedTemplateForFamily:self.family
																	entryDate:timelineEntryDate
																	isLoading:self.isUpdating
															   withConditions:self.currentConditions
													dailyForecastedConditions:self.currentDayForecasts
												   hourlyForecastedConditions:self.currentHourlyForecasts
														 airQualityConditions:self.currentAirQualityConditions
																	 location:self.city.wfLocation
															  isLocalLocation:self.city.isLocalWeatherCity
																templateBlock:^(CLKComplicationTemplate* template) {
		CLKComplicationTimelineEntry* timelineEntry = [CLKComplicationTimelineEntry entryWithDate:timelineEntryDate complicationTemplate:template];
		handler(timelineEntry);
	}];
}

@end