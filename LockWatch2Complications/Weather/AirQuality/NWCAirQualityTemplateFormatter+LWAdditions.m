//
// NWCAirQualityTemplateFormatter+LWAdditions.m
// LockWatch
//
// Created by janikschmidt on 7/1/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <WeatherFoundation/WeatherFoundation.h>

#import "NWCAirQualityTemplateFormatter+LWAdditions.h"

#if __cplusplus
extern "C" {
#endif

NSString* NWCLocalizedString(NSString* key, NSString* comment);

#if __cplusplus
}
#endif


@implementation NWCAirQualityTemplateFormatter (LWAdditions)

- (CLKComplicationTemplate*)_modularLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFAirQualityConditions*)conditions isLoading:(BOOL)isLoading {
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

- (CLKComplicationTemplate*)_utilitarianLargeTemplateForLocation:(WFLocation*)location isLocalLocation:(BOOL)isLocalLocation conditions:(WFAirQualityConditions*)conditions isLoading:(BOOL)isLoading {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [self utilitarianLargeTemplateForLocation:location conditions:conditions];
	
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
		  withAirQualityConditions:(WFAirQualityConditions*)airQualityConditions
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	switch (family) {
		case NTKComplicationFamilyModularSmall:
			template = [self modularSmallTemplateForLocation:location conditions:airQualityConditions];
			break;
		case NTKComplicationFamilyModularLarge:
			template = [self _modularLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:airQualityConditions isLoading:isLoading];
			break;
		case NTKComplicationFamilyUtilitarianSmall:
		case NTKComplicationFamilyUtilitarianSmallFlat:
			template = [self utilitarianSmallTemplateForConditions:airQualityConditions];
			break;
		case NTKComplicationFamilyUtilitarianLarge:
			template = [self _utilitarianLargeTemplateForLocation:location isLocalLocation:isLocalLocation conditions:airQualityConditions isLoading:isLoading];
			break;
		case NTKComplicationFamilyCircularSmall:
			template = [self circularSmallTemplateForConditions:airQualityConditions];
			break;
		case NTKComplicationFamilyExtraLarge:
			template = [self extraLargeTemplateForConditions:airQualityConditions];
			break;
		case NTKComplicationFamilyGraphicCorner:
			template = [self graphicCornerTemplateForConditions:airQualityConditions location:location];
			break;
		case NTKComplicationFamilyGraphicBezel:
			template = [self graphicBezelTemplateForConditions:airQualityConditions location:location];
			break;
		case NTKComplicationFamilyGraphicCircular:
			template = [self graphicCircularTemplateForConditions:airQualityConditions location:location];
			break;
		case NTKComplicationFamilyCircularMedium:
			template = [self circularMediumTemplateForConditions:airQualityConditions];
			break;
		default: break;
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}
@end