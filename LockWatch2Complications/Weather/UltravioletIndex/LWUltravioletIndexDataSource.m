//
// LWUltravioletIndexDataSource.m
// LockWatch
//
// Created by janikschmidt on 7/2/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWUltravioletIndexDataSource.h"
#import "NWCUltravioletIndexTemplateFormatter+LWAdditions.h"

@implementation LWUltravioletIndexDataSource

+ (id)bundleIdentifier {
	return @"com.apple.weather.uvi";
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (!self.currentConditions && !self.switcherTemplate) {
		if (self.family == CLKComplicationFamilyUtilLargeNarrow) return [[NWCUltravioletIndexTemplateFormatter sharedFormatter] switcherTemplateWithFamily:CLKComplicationFamilyUtilitarianLarge];
		return [[NWCUltravioletIndexTemplateFormatter sharedFormatter] switcherTemplateWithFamily:self.family];
	}
	
	return [super currentSwitcherTemplate];
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	NSDate* timelineEntryDate = NSDate.date;
	
	[[NWCUltravioletIndexTemplateFormatter sharedFormatter] formattedTemplateForFamily:self.family
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