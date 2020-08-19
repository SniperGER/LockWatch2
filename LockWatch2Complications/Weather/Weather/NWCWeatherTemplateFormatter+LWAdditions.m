//
// NWCWeatherTemplateFormatter+LWAdditions.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "NWCWeatherTemplateFormatter+LWAdditions.h"

extern NSString* NWCLocalizedString(NSString* key, NSString* comment);

@implementation NWCWeatherTemplateFormatter (LWAdditions)

- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation airQualityConditions:(WFAirQualityConditions* _Nullable)airQualityConditions conditions:(WFWeatherConditions*)conditions dailyForecastedConditions:(WFWeatherConditions*)dayForecast isLoading:(BOOL)isLoading {
	CLKComplicationTemplateModularLargeStandardBody* template = [self modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation airQualityConditions:airQualityConditions conditions:conditions dailyForecastedConditions:dayForecast];
	
	if (!conditions) {
		NSString* headerText;
		if (isLoading) {
			headerText = NWCLocalizedString(@"LOADING_SHORT", @"Loading Weather");
		} else {
			headerText = NWCLocalizedString(@"WEATHER", @"Weather");
		}
		
		[template setHeaderTextProvider:[CLKSimpleTextProvider textProviderWithText:headerText]];
	}
	
	return template;
}

- (CLKComplicationTemplate*)_utilitarianLargeTemplateForConditions:(WFWeatherConditions*)conditions isLoading:(BOOL)isLoading {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [self utilitarianLargeTemplateForConditions:conditions];
	
	if (!conditions) {
		NSString* text;
		if (isLoading) {
			text = NWCLocalizedString(@"LOADING_SHORT", @"Loading Weather");
		} else {
			text = NWCLocalizedString(@"WEATHER", @"Weather");
		}
		
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[text localizedUppercaseString]]];
	}
	
	return template;
}

- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
					withConditions:(WFWeatherConditions*)conditions
		 dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
	    hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
			  airQualityConditions:(WFAirQualityConditions* _Nullable)airQualityConditions
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	switch (family) {
		case CLKComplicationFamilyModularSmall:
			template = [self modularSmallTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation airQualityConditions:nil conditions:conditions dailyForecastedConditions:dayForecasts[0] isLoading:isLoading];
			break;
		case CLKComplicationFamilyUtilitarianSmall:
		case CLKComplicationFamilyUtilitarianSmallFlat:
			template = [self utilitarianSmallTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			template = [self _utilitarianLargeTemplateForConditions:conditions isLoading:isLoading];
			break;
		case CLKComplicationFamilyCircularSmall:
			template = [self circularSmallTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyExtraLarge:
			template = [self extraLargeTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyGraphicCorner:
			template = [self graphicCornerTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicBezel:
			template = [self graphicBezelTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case CLKComplicationFamilyGraphicCircular:
			template = [self graphicCircularTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case CLKComplicationFamilyCircularMedium:
			template = [self circularMediumTemplateForConditions:conditions];
			break;
		default: break;
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}
@end