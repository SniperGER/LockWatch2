//
// LWChanceRainComplicationDataSource.m
// LockWatch [SSH: janiks-mac-mini.local]
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWChanceRainComplicationDataSource.h"
#import "NWCChanceRainTemplateFormatter+LWAdditions.h"

@implementation LWChanceRainComplicationDataSource

+ (id)bundleIdentifier {
	return @"com.apple.weather.precipitation.chance";
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!self.currentConditions && !self.switcherTemplate) return [[NWCChanceRainTemplateFormatter sharedFormatter] switcherTemplateWithFamily:self.family];
	
	return [super currentSwitcherTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NSDate* timelineEntryDate = NSDate.date;
	
	[[NWCChanceRainTemplateFormatter sharedFormatter] formattedTemplateForFamily:self.family
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