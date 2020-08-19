//
// NWCWeatherTemplateFormatter+LWAdditions.h
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoWeatherComplicationsCompanion/NWCWeatherTemplateFormatter.h>
#import "CLKComplicationFamily.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTemplate, WFAirQualityConditions, WFWeatherConditions;

@interface NWCWeatherTemplateFormatter (LWAdditions)

- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation airQualityConditions:(WFAirQualityConditions* _Nullable)airQualityConditions conditions:(WFWeatherConditions*)conditions dailyForecastedConditions:(WFWeatherConditions*)dayForecast isLoading:(BOOL)isLoading;
- (CLKComplicationTemplate*)_utilitarianLargeTemplateForConditions:(WFWeatherConditions*)conditions isLoading:(BOOL)isLoading;
- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
					withConditions:(WFWeatherConditions*)conditions
		 dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
	    hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
			  airQualityConditions:(WFAirQualityConditions* _Nullable)airQualityConditions
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;

@end

NS_ASSUME_NONNULL_END