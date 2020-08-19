//
// LWNowPlayingTimelineEntry.h
// LockWatch
//
// Created by janikschmidt on 8/5/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoTimeKitCompanion/NTKTimelineEntryModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWNowPlayingState) {
/*  0 */	LWNowPlayingStateNotPlaying,
/*  1 */	LWNowPlayingStatePaused,
/*  2 */	LWNowPlayingStatePlaying
};

@class MPUNowPlayingController;

@interface LWNowPlayingTimelineEntry : NTKTimelineEntryModel {
	LWNowPlayingState _state;
	NSString* _title;
	NSString* _album;
	NSString* _artist;
	CGFloat _duration;
	CGFloat _elapsedTime;
	NSString* _applicationName;
}

- (instancetype)initAsSwitcherTemplate;
- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingController:(MPUNowPlayingController*)nowPlayingController applicationDisplayName:(_Nullable id)applicationDisplayName;

- (NTKOverrideTextProvider*)_italicTextProviderForText:(NSString*)text;
- (NSDate*)_projectedEndDate;
- (NSDate*)_projectedStartDate;
- (CLKComplicationTemplate*)musicTemplateForComplicationFamily:(NSInteger)family;
- (UIColor*)musicTintColor;
- (CLKComplicationTemplate*)nowPlayingTemplateForComplicationFamily:(NSInteger)family;
- (UIColor*)nowPlayingTintColor;
- (CLKComplicationTemplate*)podcastTemplateForComplicationFamily:(NSInteger)family;
- (UIColor*)podcastTintColor;
- (CLKComplicationTemplate*)radioTemplateForComplicationFamily:(NSInteger)family;
- (UIColor*)radioTintColor;

- (CLKComplicationTemplate*)_music_extraLarge;
- (CLKComplicationTemplate*)_music_largeModular;
- (CLKComplicationTemplate*)_music_largeUtility;
- (CLKComplicationTemplate*)_music_mediumCircular;
- (CLKComplicationTemplate*)_music_signatureBezel;
- (CLKComplicationTemplate*)_music_signatureCircular;
- (CLKComplicationTemplate*)_music_signatureCorner;
- (CLKComplicationTemplate*)_music_signatureRectangular;
- (CLKComplicationTemplate*)_music_smallModular;
- (CLKComplicationTemplate*)_music_smallUtility;

- (CLKComplicationTemplate*)_nowPlaying_largeModular;
- (CLKComplicationTemplate*)_nowPlaying_largeUtility;
- (CLKComplicationTemplate*)_nowPlaying_signatureRectangular;

- (CLKComplicationTemplate*)_podcast_extraLarge;
- (CLKComplicationTemplate*)_podcast_largeModular;
- (CLKComplicationTemplate*)_podcast_largeUtility;
- (CLKComplicationTemplate*)_podcast_mediumCircular;
- (CLKComplicationTemplate*)_podcast_signatureBezel;
- (CLKComplicationTemplate*)_podcast_signatureCircular;
- (CLKComplicationTemplate*)_podcast_signatureCorner;
- (CLKComplicationTemplate*)_podcast_signatureRectangular;
- (CLKComplicationTemplate*)_podcast_smallCircular;
- (CLKComplicationTemplate*)_podcast_smallModular;
- (CLKComplicationTemplate*)_podcast_smallUtility;

- (CLKComplicationTemplate*)_radio_extraLarge;
- (CLKComplicationTemplate*)_radio_largeModular;
- (CLKComplicationTemplate*)_radio_largeUtility;
- (CLKComplicationTemplate*)_radio_mediumCircular;
- (CLKComplicationTemplate*)_radio_signatureBezel;
- (CLKComplicationTemplate*)_radio_signatureCircular;
- (CLKComplicationTemplate*)_radio_signatureCorner;
- (CLKComplicationTemplate*)_radio_signatureRectangular;
- (CLKComplicationTemplate*)_radio_smallCircular;
- (CLKComplicationTemplate*)_radio_smallModular;
- (CLKComplicationTemplate*)_radio_smallUtility;

@end

NS_ASSUME_NONNULL_END