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

#if __cplusplus
extern "C" {
#endif

NSString* NWCLocalizedString(NSString* key, NSString* comment);

#if __cplusplus
}
#endif


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

- (void)formattedTemplateForFamily:(NTKComplicationFamily)family
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
		case NTKComplicationFamilyModularSmall:
			template = [self modularSmallTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation airQualityConditions:nil conditions:conditions dailyForecastedConditions:dayForecasts[0] isLoading:isLoading];
			break;
		case NTKComplicationFamilyUtilitarianSmall:
		case NTKComplicationFamilyUtilitarianSmallFlat:
			template = [self utilitarianSmallTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyUtilitarianLarge:
			template = [self _utilitarianLargeTemplateForConditions:conditions isLoading:isLoading];
			break;
		case NTKComplicationFamilyCircularSmall:
			template = [self circularSmallTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyExtraLarge:
			template = [self extraLargeTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyGraphicCorner:
			template = [self graphicCornerTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case NTKComplicationFamilyGraphicBezel:
			template = [self graphicBezelTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case NTKComplicationFamilyGraphicCircular:
			template = [self graphicCircularTemplateForCurrentObservations:conditions dailyForecastedConditions:dayForecasts[0]];
			break;
		case NTKComplicationFamilyCircularMedium:
			template = [self circularMediumTemplateForConditions:conditions];
			break;
		default: break;
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}
@end