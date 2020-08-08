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
	NSString* _applicationName;
}

- (instancetype)initAsSwitcherTemplate;
- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingController:(MPUNowPlayingController*)nowPlayingController applicationDisplayName:(_Nullable id)applicationDisplayName;
- (NTKOverrideTextProvider*)_italicTextProviderForText:(NSString*)text;
- (CLKComplicationTemplate*)musicTemplateForComplicationFamily:(NSInteger)family;
- (CLKComplicationTemplate*)nowPlayingTemplateForComplicationFamily:(NSInteger)family;
- (CLKComplicationTemplate*)podcastTemplateForComplicationFamily:(NSInteger)family;
- (CLKComplicationTemplate*)radioTemplateForComplicationFamily:(NSInteger)family;
@end

NS_ASSUME_NONNULL_END