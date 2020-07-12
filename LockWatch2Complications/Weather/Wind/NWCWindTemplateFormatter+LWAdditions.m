//
// NWCWindTemplateFormatter+LWAdditions.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <NanoWeatherComplicationsCompanion/NanoWeatherComplicationsCompanion.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "NWCWindTemplateFormatter+LWAdditions.h"

#if __cplusplus
extern "C" {
#endif

NSString* NWCLocalizedString(NSString* key, NSString* comment);
NSArray* NWCPlaceholderHourlyConditionsStartingAtDate(NSDate*, int);

#if __cplusplus
}
#endif

@implementation NWCWindTemplateFormatter (LWAdditions)


- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
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
		
		NSDate* _currentConditionsDate = [(NSDateComponents*)[conditions objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		NSDate* _forecastDate = [(NSDateComponents*)[hourlyForecasts[0] objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		
		if ([_forecastDate compare:_currentConditionsDate] == NSOrderedAscending) {
			[hourlyConditions replaceObjectAtIndex:0 withObject:conditions];
		} else {
			hourlyConditions = [[@[conditions] arrayByAddingObjectsFromArray:[hourlyConditions subarrayWithRange:NSMakeRange(0, 4)]] mutableCopy];
		}
		
		template = [self graphicRectangularTemplateForLocalLocation:isLocalLocation timeZone:timeZone conditions:conditions hourlyForecastedConditions:hourlyConditions];
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}

- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFWeatherConditions*)conditions isLoading:(BOOL)isLoading {
	CLKComplicationTemplateModularLargeStandardBody* template = [self modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:conditions];
	
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
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	switch (family) {
		case NTKComplicationFamilyModularSmall:
			template = [self modularSmallTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:conditions isLoading:isLoading];
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
			template = [self graphicCornerTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyGraphicBezel:
			template = [self graphicBezelTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyGraphicCircular:
			template = [self graphicCircularTemplateForConditions:conditions];
			break;
		case NTKComplicationFamilyGraphicRectangular:
			[self _graphicRectangularTemplateForEntryDate:entryDate isLocalLocation:isLocalLocation conditions:conditions hourlyForecastedConditions:hourlyForecasts timeZone:location.timeZone isLoading:isLoading templateBlock:templateBlock];
			return;
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