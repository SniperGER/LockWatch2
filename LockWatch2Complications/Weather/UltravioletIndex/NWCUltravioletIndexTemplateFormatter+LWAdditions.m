//
// NWCUltravioletIndexTemplateFormatter+LWAdditions.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <NanoWeatherComplicationsCompanion/NanoWeatherComplicationsCompanion.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "NWCUltravioletIndexTemplateFormatter+LWAdditions.h"

extern NSString* NWCLocalizedString(NSString* key, NSString* comment);
extern NSArray* NWCPlaceholderDailyConditionsStartingAtDate(NSDate* date, int count);

@implementation NWCUltravioletIndexTemplateFormatter (LWAdditions)

- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
					   dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
								        timeZone:(NSTimeZone*)timeZone
								       isLoading:(BOOL)isLoading
								   templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	if (!conditions || dayForecasts.count < 7) {
		NSString* text = NWCLocalizedString(isLoading ? @"LOADING_LONG" : @"WEATHER", @"Weather / Loading Weather Data");
		
		CLKSimpleTextProvider* textProvider = [CLKSimpleTextProvider textProviderWithText:[text localizedUppercaseString]];
		[textProvider setTintColor:NWCColor.titleNoDataColor];
		
		NSArray* placeholderConditions = NWCPlaceholderDailyConditionsStartingAtDate(entryDate, 7);
		
		template = [self _graphicRectangularTemplateWithTextProvider:textProvider conditions:placeholderConditions.firstObject sevenDayDailyForecastedConditions:placeholderConditions timeZone:timeZone];
	} else {
		NSMutableArray* dailyConditions = [NSMutableArray arrayWithCapacity:7];
		
		[dayForecasts enumerateObjectsUsingBlock:^(WFWeatherConditions* forecast, NSUInteger index, BOOL* stop) {
			[dailyConditions addObject:forecast];
			*stop = dailyConditions.count >= 7;
		}];
		
		NSDate* _currentConditionsDate = [(NSDateComponents*)[conditions objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		NSDate* _forecastDate = [(NSDateComponents*)[dayForecasts.firstObject objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		
		if ([_forecastDate compare:_currentConditionsDate] == NSOrderedAscending) {
			[dailyConditions replaceObjectAtIndex:0 withObject:conditions];
		} else {
			dailyConditions = [[@[conditions] arrayByAddingObjectsFromArray:[dailyConditions subarrayWithRange:NSMakeRange(0, 6)]] mutableCopy];
		}
		
		template = [self graphicRectangularTemplateForLocalLocation:isLocalLocation timeZone:timeZone conditions:conditions dailyForecastedConditions:dailyConditions];
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

- (void)formattedTemplateForFamily:(CLKComplicationFamily)family
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
		case CLKComplicationFamilyModularSmall:
			template = [self modularSmallTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:conditions isLoading:isLoading];
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
			template = [self graphicCornerTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyGraphicBezel:
			template = [self graphicBezelTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyGraphicCircular:
			template = [self graphicCircularTemplateForConditions:conditions];
			break;
		case CLKComplicationFamilyGraphicRectangular:
			[self _graphicRectangularTemplateForEntryDate:entryDate isLocalLocation:isLocalLocation conditions:conditions dailyForecastedConditions:dayForecasts timeZone:location.timeZone isLoading:isLoading templateBlock:templateBlock];
			return;
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