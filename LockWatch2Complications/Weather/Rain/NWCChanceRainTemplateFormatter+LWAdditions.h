//
// NWCChanceRainTemplateFormatter+LWAdditions.h
// LockWatch
//
// Created by janikschmidt on 8/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "CLKComplicationFamily.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTemplate, WFLocation, WFWeatherConditions;

@interface NWCChanceRainTemplateFormatter : NSObject
+ (instancetype)sharedFormatter;
- (id)switcherTemplateWithFamily:(long long)arg1;
- (id)_circularMediumTemplateForConditions:(id)arg1;
- (id)_circularSmallTemplateForConditions:(id)arg1;
- (id)_extraLargeTemplateForConditions:(id)arg1;
- (id)_graphicBezelTemplateForConditions:(id)arg1;
- (id)_graphicCircularTemplateForConditions:(id)arg1;
- (id)_graphicCornerTemplateForConditions:(id)arg1;
- (id)_graphicRectangularTemplateWithTextProvider:(id)arg1 hourlyForecastedConditions:(id)arg2 timeZone:(id)arg3;
- (id)_graphicRectangularTemplateForLocalLocation:(BOOL)arg1 timeZone:(id)arg2 conditions:(id)arg3 hourlyForecastedConditions:(id)arg4;
- (id)_modularLargeTemplateForLocation:(id)arg1 isLocalLocation:(BOOL)arg2 conditions:(id)arg3;
- (id)_modularSmallTemplateForConditions:(id)arg1;
- (id)_utilitarianLargeTemplateForConditions:(id)arg1;
- (id)_circularMediumTemplateForConditions:(id)arg1;
- (id)_utilitarianSmallTemplateForConditions:(id)arg1;
@end

@interface NWCChanceRainTemplateFormatter (LWAdditions)

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