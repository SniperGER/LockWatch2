//
// NWCAirQualityTemplateFormatter+LWAdditions.h
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoWeatherComplicationsCompanion/NWCAirQualityTemplateFormatter.h>
#import "CLKComplicationFamily.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTemplate, WFAirQualityConditions;

@interface NWCAirQualityTemplateFormatter (LWAdditions)

- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFAirQualityConditions*)conditions isLoading:(BOOL)isLoading;
- (CLKComplicationTemplate*)_utilitarianLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFAirQualityConditions*)conditions isLoading:(BOOL)isLoading;
- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
		  withAirQualityConditions:(WFAirQualityConditions*)airQualityConditions
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock;

@end

NS_ASSUME_NONNULL_END