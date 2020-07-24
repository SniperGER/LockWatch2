//
// LWNowPlayingTimelineEntry.m
// LockWatch
//
// Created by janikschmidt on 4/4/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <NanoTimeKitCompanion/NTKOverrideTextProvider.h>

#import "LWNowPlayingTimelineEntry.h"
#import "NTKComplicationFamily.h"

#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0]

extern NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);
extern UIImage* NTKImageNamed(NSString* imageName);

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;

@implementation LWNowPlayingTimelineEntry

- (instancetype)initAsSwitcherTemplate {
	if (self = [super init]) {
		_state = 0;
		
		[self setEntryDate:[NSDate date]];
	}
	
	return self;
}

- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingInfo:(NSDictionary*)nowPlayingInfo applicationName:(NSString*)applicationName {
	if (self = [super init]) {
		_state = state;
		
		if (state != LWNowPlayingStateNotPlaying) {
			_title = nowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle];
			_album = nowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoAlbum];
			_artist = nowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist];
			_applicationName = applicationName;
		}
		
		[self setEntryDate:[NSDate date]];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (CLKComplicationTemplateGraphicRectangularStandardBody*)_graphicRectangular {
	CLKComplicationTemplateGraphicRectangularStandardBody* template = [CLKComplicationTemplateGraphicRectangularStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	CLKSimpleTextProvider* body2TextProvider;
	
	if (_state != LWNowPlayingStatePlaying) {
		if (_state != LWNowPlayingStatePaused) {
			if (_state == LWNowPlayingStateNotPlaying) {
				headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_HEADER_LARGE_MODULAR", @"Now Playing")];
				[headerTextProvider setTintColor:SYSTEM_BLUE_COLOR];
				
				body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_MODULAR", @"Tap to open")];
			}
		} else {
			headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
			[headerTextProvider setTintColor:SYSTEM_BLUE_COLOR];
			
			NSMutableArray* titleArray = [NSMutableArray array];
			if (_artist.length > 0) {
				[titleArray addObject:_artist];
			}
			
			if (_album.length > 0) {
				[titleArray addObject:_album];
			}
			
			NSString* titleString = [titleArray componentsJoinedByString:@" - "];
			
			body1TextProvider = [CLKSimpleTextProvider textProviderWithText:titleString];
			body2TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_PAUSED_LARGE_MODULAR", @"Paused")];
		}
	} else {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		[headerTextProvider setTintColor:SYSTEM_BLUE_COLOR];
		
		NSMutableArray* titleArray = [NSMutableArray array];
		if (_artist.length > 0) {
			[titleArray addObject:_artist];
		}
		
		if (_album.length > 0) {
			[titleArray addObject:_album];
		}
		
		NSString* titleString = [titleArray componentsJoinedByString:@" - "];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:titleString];
		body2TextProvider = [CLKSimpleTextProvider textProviderWithText:_applicationName];
		
		// [template setHeaderImageProvider:[CLKImageProvider imageProviderWithOnePieceImage:[NTKImageNamed(@"modularLargeMusicEqualizer") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]];
		[template setHeaderImageProvider:[CLKFullColorImageProvider providerWithFullColorImage:[NTKImageNamed(@"modularLargeMusicEqualizer") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] monochromeFilterType:1 applyScalingAndCircularMasking:NO]];
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:SYSTEM_BLUE_COLOR];
	
	return template;
}

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

- (CLKComplicationTemplateModularLargeStandardBody*)_largeModular {
	CLKComplicationTemplateModularLargeStandardBody* template = [CLKComplicationTemplateModularLargeStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state != LWNowPlayingStatePlaying) {
		if (_state != LWNowPlayingStatePaused) {
			if (_state == LWNowPlayingStateNotPlaying) {
				headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_HEADER_LARGE_MODULAR", @"Now Playing")];
				body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_MODULAR", @"Tap to open")];
			}
		} else {
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
		}
	} else {
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
		
		[template setHeaderImageProvider:[CLKImageProvider imageProviderWithOnePieceImage:[NTKImageNamed(@"modularLargeMusicEqualizer") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]];
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

- (CLKComplicationTemplateUtilitarianLargeFlat*)_largeUtility {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [CLKComplicationTemplateUtilitarianLargeFlat new];
	
	if (_state > LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
		[template setImageProvider:[CLKImageProvider imageProviderWithOnePieceImage:[NTKImageNamed(@"utilityLongMusicEqualizer") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]];
	} else {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_UTILITY", @"TAP TO OPEN")]];
	}
	
	return template;
}

- (CLKComplicationTemplate*)templateForComplicationFamily:(long long)family {
	switch (family) {
		case NTKComplicationFamilyModularLarge: return [self _largeModular];
		case NTKComplicationFamilyUtilitarianLarge: return [self _largeUtility];
		case NTKComplicationFamilyGraphicRectangular: return [self _graphicRectangular];
	}
	
	return nil;
}

@end