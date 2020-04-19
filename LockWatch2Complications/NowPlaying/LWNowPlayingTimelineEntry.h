//
// LWNowPlayingTimelineEntry.h
// LockWatch
//
// Created by janikschmidt on 4/4/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoTimeKitCompanion/NTKTimelineEntryModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWNowPlayingState) {
/*  0 */	LWNowPlayingStateNotPlaying,
/*  1 */	LWNowPlayingStatePaused,
/*  2 */	LWNowPlayingStatePlaying
};

@class CLKComplicationTemplate, CLKComplicationTemplateGraphicRectangularStandardBody, CLKComplicationTemplateModularLargeStandardBody, CLKComplicationTemplateUtilitarianLargeFlat, NTKOverrideTextProvider;

@interface LWNowPlayingTimelineEntry : NTKTimelineEntryModel {
	NSInteger _state;
	NSString* _title;
	NSString* _album;
	NSString* _artist;
	NSString* _applicationName;
}

- (instancetype)initAsSwitcherTemplate;
- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingInfo:(NSDictionary*)nowPlayingInfo applicationName:(NSString*)applicationName;
- (CLKComplicationTemplateGraphicRectangularStandardBody*)_graphicRectangular;
- (NTKOverrideTextProvider*)_italicTextProviderForText:(NSString*)text;
- (CLKComplicationTemplateModularLargeStandardBody*)_largeModular;
- (CLKComplicationTemplateUtilitarianLargeFlat*)_largeUtility;
- (CLKComplicationTemplate*)templateForComplicationFamily:(long long)family;

@end

NS_ASSUME_NONNULL_END