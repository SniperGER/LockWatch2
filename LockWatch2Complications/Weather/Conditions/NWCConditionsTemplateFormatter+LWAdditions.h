//
// NWCConditionsTemplateFormatter+LWAdditions.h
// LockWatch
//
// Created by janikschmidt on 7/2/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoWeatherComplicationsCompanion/NWCConditionsTemplateFormatter.h>
#import "CLKComplicationFamily.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWCConditionsTemplateFormatter (LWAdditions)
- (void)_circularMediumTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_circularSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_extraLargeTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_graphicBezelTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions dailyForecastedConditions:(WFWeatherConditions*)dayForecast templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_graphicCircularTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_graphicCornerTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
					   dailyForecastedConditions:(WFWeatherConditions*)dayForecast
					  hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
								        timeZone:(NSTimeZone*)timeZone
								       isLoading:(BOOL)isLoading
								   templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_modularSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
- (void)_utilitarianSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;
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