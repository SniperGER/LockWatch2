//
// NWCChanceRainTemplateFormatter+LWAdditions.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <NanoWeatherComplicationsCompanion/NanoWeatherComplicationsCompanion.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "NWCChanceRainTemplateFormatter+LWAdditions.h"

extern NSString* NWCLocalizedString(NSString* key, NSString* comment);
extern NSArray* NWCPlaceholderHourlyConditionsStartingAtDate(NSDate* date, int count);

@implementation NWCChanceRainTemplateFormatter (LWAdditions)

- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
					   dailyForecastedConditions:(WFWeatherConditions*)dayForecast
					  hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
								        timeZone:(NSTimeZone*)timeZone
								       isLoading:(BOOL)isLoading
								   templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	if (!conditions || hourlyForecasts.count < NWCFiveHourForecastView.maximumHourlyConditionCount) {
		NSString* text = NWCLocalizedString(isLoading ? @"LOADING_LONG" : @"WEATHER", @"Weather / Loading Weather Data");
		
		CLKSimpleTextProvider* textProvider = [CLKSimpleTextProvider textProviderWithText:[text localizedUppercaseString]];
		[textProvider setTintColor:NWCColor.titleNoDataColor];
		
		template = [self _graphicRectangularTemplateWithTextProvider:textProvider hourlyForecastedConditions:NWCPlaceholderHourlyConditionsStartingAtDate(entryDate, NWCFiveHourForecastView.maximumHourlyConditionCount) timeZone:timeZone];
	} else {
		NSMutableArray* hourlyConditions = [NSMutableArray arrayWithCapacity:NWCFiveHourForecastView.maximumHourlyConditionCount];
		
		[hourlyForecasts enumerateObjectsUsingBlock:^(WFWeatherConditions* forecast, NSUInteger index, BOOL* stop) {
			[hourlyConditions addObject:forecast];
			*stop = hourlyConditions.count >= NWCFiveHourForecastView.maximumHourlyConditionCount;
		}];
		
		// NSDate* _currentConditionsDate = [(NSDateComponents*)[conditions objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		// NSDate* _forecastDate = [(NSDateComponents*)[hourlyForecasts[0] objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		
		// if ([_forecastDate compare:_currentConditionsDate] == NSOrderedAscending) {
		// 	[hourlyConditions replaceObjectAtIndex:0 withObject:conditions];
		// } else {
		// 	hourlyConditions = [[@[conditions] arrayByAddingObjectsFromArray:[hourlyConditions subarrayWithRange:NSMakeRange(0, 4)]] mutableCopy];
		// }
		
		template = [self _graphicRectangularTemplateForLocalLocation:isLocalLocation timeZone:timeZone conditions:conditions hourlyForecastedConditions:hourlyConditions];
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}

- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
					withConditions:(WFWeatherConditions*)conditions
		 dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
	    hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template = [self switcherTemplateWithFamily:family];
	
	switch (family) {
		case CLKComplicationFamilyModularSmall:
			template = [self _modularSmallTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyUtilitarianSmall:
		case CLKComplicationFamilyUtilitarianSmallFlat:
			template = [self _utilitarianSmallTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			template = [self _utilitarianLargeTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyCircularSmall:
			template = [self _circularSmallTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyExtraLarge:
			template = [self _extraLargeTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicCorner:
			template = [self _graphicCornerTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicBezel:
			template = [self _graphicBezelTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicCircular:
			template = [self _graphicCircularTemplateForConditions:hourlyForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicRectangular:
			[self _graphicRectangularTemplateForEntryDate:entryDate isLocalLocation:isLocalLocation conditions:conditions dailyForecastedConditions:dayForecasts[0] hourlyForecastedConditions:hourlyForecasts timeZone:location.timeZone isLoading:isLoading templateBlock:templateBlock];
			return;
		case CLKComplicationFamilyCircularMedium:
			template = [self _circularMediumTemplateForConditions:hourlyForecasts[0]];
			break;
		default: break;
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}
@end