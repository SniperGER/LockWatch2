//
// NWCUltravioletIndexTemplateFormatter+LWAdditions.h
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoWeatherComplicationsCompanion/NWCUltravioletIndexTemplateFormatter.h>
#import "CLKComplicationFamily.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTemplate, WFLocation, WFWeatherConditions;

@interface NWCUltravioletIndexTemplateFormatter (LWAdditions)

- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
					   dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
								        timeZone:(NSTimeZone*)timeZone
								       isLoading:(BOOL)isLoading
								   templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFWeatherConditions*)conditions isLoading:(BOOL)isLoading;
- (CLKComplicationTemplate*)_utilitarianLargeTemplateForConditions:(WFWeatherConditions*)conditions isLoading:(BOOL)isLoading;
- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
					withConditions:(WFWeatherConditions*)conditions
		 dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
	    hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;

@end

NS_ASSUME_NONNULL_END