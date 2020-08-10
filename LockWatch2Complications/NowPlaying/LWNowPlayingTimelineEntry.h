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

@end

NS_ASSUME_NONNULL_END