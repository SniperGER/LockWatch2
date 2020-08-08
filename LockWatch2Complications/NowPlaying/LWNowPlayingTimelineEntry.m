//
// LWNowPlayingTimelineEntry.m
// LockWatch
//
// Created by janikschmidt on 8/5/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <MediaPlayerUI/MediaPlayerUI.h>
#import <NanoTimeKitCompanion/NTKOverrideTextProvider.h>

#import "LWNowPlayingTimelineEntry.h"
#import "NTKComplicationFamily.h"

#define PODCAST_TINT_COLOR [UIColor colorWithRed:0.612 green:0.353 blue:0.95 alpha:1]
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0]
#define SYSTEM_PINK_COLOR [UIColor colorWithRed:1 green:0.176 blue:0.333 alpha:1.0]

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;

extern NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);
extern UIImage* NTKImageNamed(NSString* imageName);



@implementation LWNowPlayingTimelineEntry

- (instancetype)initAsSwitcherTemplate {
	if (self = [super init]) {
		_state = LWNowPlayingStateNotPlaying;
		
		[self setEntryDate:[NSDate date]];
	}
	
	return self;
}

- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingController:(MPUNowPlayingController*)nowPlayingController applicationDisplayName:(id)applicationDisplayName {
	if (self = [super init]) {
		_state = state;
		
		if (state != LWNowPlayingStateNotPlaying) {
			_title = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle];
			_album = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoAlbum];
			_artist = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist];
			_applicationName = applicationDisplayName;
		}
		
		[self setEntryDate:[NSDate date]];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (NTKOverrideTextProvider*)_italicTextProviderForText:(NSString*)text {
	return [NTKOverrideTextProvider textProviderWithText:text overrideBlock:^(NSString* text, unsigned long long arg2, CLKTextProviderStyle* style) {
		NSAttributedString* attributedString = nil;
		
		if (text && arg2 == 0) {
			if (style.uppercase) {
				text = [text uppercaseStringWithLocale:NSLocale.currentLocale];
			}
			
			CLKFont* font = [CLKFont fontWithDescriptor:[style.font.fontDescriptor fontDescriptorWithSymbolicTraits:1] size:style.font.pointSize];
			
			attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{
				NSFontAttributeName: font
			}];
		}
		
		return attributedString;
	}];
}

- (CLKComplicationTemplate*)musicTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case NTKComplicationFamilyModularLarge: return [self _music_largeModular];
	}
	
	return nil;
}

- (CLKComplicationTemplate*)nowPlayingTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case NTKComplicationFamilyModularLarge: return [self _nowPlaying_largeModular];
		// case NTKComplicationFamilyUtilitarianLarge: return [self _largeUtility];
		// case NTKComplicationFamilyGraphicRectangular: return [self _graphicRectangular];
	}
	
	return nil;
}

- (CLKComplicationTemplate*)podcastTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case NTKComplicationFamilyModularLarge: return [self _podcast_largeModular];
	}
	
	return nil;
}

- (CLKComplicationTemplate*)radioTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case NTKComplicationFamilyModularLarge: return [self _radio_largeModular];
	}
	
	return nil;
}

#pragma mark - Music

- (CLKComplicationTemplateModularLargeStandardBody*)_music_largeModular {
	CLKComplicationTemplateModularLargeStandardBody* template = [CLKComplicationTemplateModularLargeStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_HEADER_LARGE_MODULAR", @"Music")];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_LARGE_MODULAR", @"Tap to play music")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:_album];
		
		// LWNowPlayingIndicatorImageProvider* imageProvider;
		// if (@available(iOS 13, *)) {
		// 	imageProvider = [self _nowPlayingProviderForFamily:1 tintColor:UIColor.systemPinkColor];
		// } else {
		// 	imageProvider = [self _nowPlayingProviderForFamily:1 tintColor:SYSTEM_PINK_COLOR];
		// }
		
		// if (imageProvider) {
		// 	[template setHeaderImageProvider:imageProvider];
		// }
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	if (@available(iOS 13, *)) {
		[template setTintColor:UIColor.systemPinkColor];
	} else {
		[template setTintColor:SYSTEM_PINK_COLOR];
	}
	
	return template;
}

#pragma mark - Now Playing

- (CLKComplicationTemplateModularLargeStandardBody*)_nowPlaying_largeModular {
	CLKComplicationTemplateModularLargeStandardBody* template = [CLKComplicationTemplateModularLargeStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_HEADER_LARGE_MODULAR", @"Now Playing")];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_MODULAR", @"Tap to open")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		
		NSMutableArray* titleArray = [NSMutableArray array];
		if (_artist.length > 0) {
			[titleArray addObject:_artist];
		}
		
		if (_album.length > 0) {
			[titleArray addObject:_album];
		}
		
		NSString* titleString = [titleArray componentsJoinedByString:@" - "];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:titleString];
		
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"NOW_PLAYING_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		
		NSMutableArray* titleArray = [NSMutableArray array];
		if (_artist.length > 0) {
			[titleArray addObject:_artist];
		}
		
		if (_album.length > 0) {
			[titleArray addObject:_album];
		}
		
		NSString* titleString = [titleArray componentsJoinedByString:@" - "];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:titleString];
		body2TextProvider = [self _italicTextProviderForText:_applicationName];
		
		// LWNowPlayingIndicatorImageProvider* imageProvider;
		// if (@available(iOS 13, *)) {
		// 	imageProvider = [self _nowPlayingProviderForFamily:1 tintColor:UIColor.systemBlueColor];
		// } else {
		// 	imageProvider = [self _nowPlayingProviderForFamily:1 tintColor:SYSTEM_BLUE_COLOR];
		// }
		
		// if (imageProvider) {
		// 	[template setHeaderImageProvider:imageProvider];
		// }
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	if (@available(iOS 13, *)) {
		[template setTintColor:UIColor.systemBlueColor];
	} else {
		[template setTintColor:SYSTEM_BLUE_COLOR];
	}
	
	return template;
}

#pragma mark - Radio

- (CLKComplicationTemplateModularLargeStandardBody*)_radio_largeModular {
	CLKComplicationTemplateModularLargeStandardBody* template = [CLKComplicationTemplateModularLargeStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_STOPPED_HEADER_LARGE_MODULAR", @"Radio")];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_LARGE_MODULAR", @"Tap to play radio")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"RADIO_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:_album];
	
		[template setHeaderImageProvider:[CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"ModularLargeRadio")]];
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	if (@available(iOS 13, *)) {
		[template setTintColor:UIColor.systemPinkColor];
	} else {
		[template setTintColor:SYSTEM_PINK_COLOR];
	}
	
	return template;
}

#pragma mark - Podcasts

- (CLKComplicationTemplateModularLargeStandardBody*)_podcast_largeModular {
	CLKComplicationTemplateModularLargeStandardBody* template = [CLKComplicationTemplateModularLargeStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_STOPPED_HEADER_LARGE_MODULAR", @"Podcasts")];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_LARGE_MODULAR", @"Tap to play podcasts")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"PODCAST_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		
		// LWNowPlayingIndicatorImageProvider* imageProvider = [self _nowPlayingProviderForFamily:1 tintColor:PODCAST_TINT_COLOR];
		
		// if (imageProvider) {
		// 	[template setHeaderImageProvider:imageProvider];
		// }
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:PODCAST_TINT_COLOR];
	
	return template;
}

@end