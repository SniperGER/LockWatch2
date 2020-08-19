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

#import "CLKComplicationFamily.h"
#import "LWNowPlayingTimelineEntry.h"
#import "NowPlayingIndicator/LWNowPlayingIndicatorFullColorProvider.h"
#import "NowPlayingIndicator/LWNowPlayingIndicatorProvider.h"

#define PODCAST_TINT_COLOR [UIColor colorWithRed:0.612 green:0.353 blue:0.95 alpha:1]
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0]
#define SYSTEM_PINK_COLOR [UIColor colorWithRed:1 green:0.176 blue:0.333 alpha:1.0]

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
extern CFStringRef kMRMediaRemoteNowPlayingInfoDuration;
extern CFStringRef kMRMediaRemoteNowPlayingInfoElapsedTime;

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

- (instancetype)initWithState:(LWNowPlayingState)state nowPlayingController:(MPUNowPlayingController*)nowPlayingController applicationDisplayName:(_Nullable id)applicationDisplayName {
	if (self = [super init]) {
		_state = state;
		
		if (state != LWNowPlayingStateNotPlaying) {
			_title = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle];
			_album = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoAlbum];
			_artist = nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist];
			_duration = [nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration] floatValue];
			_elapsedTime = [nowPlayingController.currentNowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoElapsedTime] floatValue];
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

- (NSDate*)_projectedEndDate {
	return [[self entryDate] dateByAddingTimeInterval:-_elapsedTime + _duration];
}

- (NSDate*)_projectedStartDate {
	return [[self entryDate] dateByAddingTimeInterval:-_elapsedTime];
}

- (CLKComplicationTemplate*)musicTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case CLKComplicationFamilyModularSmall: return [self _music_smallModular];
		case CLKComplicationFamilyModularLarge: return [self _music_largeModular];
		case CLKComplicationFamilyUtilitarianSmall: return [self _music_smallUtility];
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			return [self _music_largeUtility];
		case CLKComplicationFamilyExtraLarge: return [self _music_extraLarge];
		case CLKComplicationFamilyGraphicCorner: return [self _music_signatureCorner];
		case CLKComplicationFamilyGraphicBezel: return [self _music_signatureBezel];
		case CLKComplicationFamilyGraphicCircular: return [self _music_signatureCircular];
		case CLKComplicationFamilyGraphicRectangular: return [self _music_signatureRectangular];
		case CLKComplicationFamilyCircularMedium: return [self _music_mediumCircular];
	}
	
	return nil;
}

- (UIColor*)musicTintColor {
	if (@available(iOS 13, *)) {
		return UIColor.systemPinkColor;
	} else {
		return SYSTEM_PINK_COLOR;
	}
}

- (CLKComplicationTemplate*)nowPlayingTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case CLKComplicationFamilyModularLarge: return [self _nowPlaying_largeModular];
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			return [self _nowPlaying_largeUtility];
		case CLKComplicationFamilyGraphicRectangular: return [self _nowPlaying_signatureRectangular];
	}
	
	return nil;
}

- (UIColor*)nowPlayingTintColor {
	if (@available(iOS 13, *)) {
		return UIColor.systemBlueColor;
	} else {
		return SYSTEM_BLUE_COLOR;
	}
}

- (CLKComplicationTemplate*)podcastTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case CLKComplicationFamilyModularSmall: return [self _podcast_smallModular];
		case CLKComplicationFamilyModularLarge: return [self _podcast_largeModular];
		case CLKComplicationFamilyUtilitarianSmall: return [self _podcast_smallUtility];
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			return [self _podcast_largeUtility];
		case CLKComplicationFamilyCircularSmall: return [self _podcast_smallCircular];
		case CLKComplicationFamilyExtraLarge: return [self _podcast_extraLarge];
		case CLKComplicationFamilyGraphicCorner: return [self _podcast_signatureCorner];
		case CLKComplicationFamilyGraphicBezel: return [self _podcast_signatureBezel];
		case CLKComplicationFamilyGraphicCircular: return [self _podcast_signatureCircular];
		case CLKComplicationFamilyGraphicRectangular: return [self _podcast_signatureRectangular];
		case CLKComplicationFamilyCircularMedium: return [self _podcast_mediumCircular];
	}
	
	return nil;
}

- (UIColor*)podcastTintColor {
	return PODCAST_TINT_COLOR;
}

- (CLKComplicationTemplate*)radioTemplateForComplicationFamily:(NSInteger)family {
	switch (family) {
		case CLKComplicationFamilyModularSmall: return [self _radio_smallModular];
		case CLKComplicationFamilyModularLarge: return [self _radio_largeModular];
		case CLKComplicationFamilyUtilitarianSmall: return [self _radio_smallUtility];
		case CLKComplicationFamilyUtilitarianLarge:
		case CLKComplicationFamilyUtilLargeNarrow:
			return [self _radio_largeUtility];
		case CLKComplicationFamilyCircularSmall: return [self _radio_smallCircular];
		case CLKComplicationFamilyExtraLarge: return [self _radio_extraLarge];
		case CLKComplicationFamilyGraphicCorner: return [self _radio_signatureCorner];
		case CLKComplicationFamilyGraphicBezel: return [self _radio_signatureBezel];
		case CLKComplicationFamilyGraphicCircular: return [self _radio_signatureCircular];
		case CLKComplicationFamilyGraphicRectangular: return [self _radio_signatureRectangular];
		case CLKComplicationFamilyCircularMedium: return [self _radio_mediumCircular];
	}
	
	return nil;
}

- (UIColor*)radioTintColor {
	if (@available(iOS 13, *)) {
		return UIColor.systemPinkColor;
	} else {
		return SYSTEM_PINK_COLOR;
	}
}

#pragma mark - Music

- (CLKComplicationTemplate*)_music_extraLarge {
	if (_state != LWNowPlayingStatePlaying) {
		CLKComplicationTemplateExtraLargeSimpleImage* template = [CLKComplicationTemplateExtraLargeSimpleImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"XLmodularMusicPaused")];
		[imageProvider setTintColor:[self musicTintColor]];
		
		[template setImageProvider:imageProvider];
		
		return template;
	} else {
		CLKComplicationTemplateExtraLargeProgressRingImage* template = [CLKComplicationTemplateExtraLargeProgressRingImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"XLmodularMusic")];
		[template setImageProvider:imageProvider];
		
		[imageProvider setTintColor:UIColor.whiteColor];
		
		NSDate* startDate = [self _projectedStartDate];
		NSDate* endDate = [startDate dateByAddingTimeInterval:_duration];
		
		CLKRelativeDateProgressProvider* progressProvider = [CLKRelativeDateProgressProvider relativeDateProgressProviderWithStartDate:startDate endDate:endDate];
		[progressProvider setTintColor:[self musicTintColor]];
		
		[template setProgressProvider:progressProvider];
		[template setRingStyle:0];
		
		return template;
	}
	
	return nil;
}

- (CLKComplicationTemplate*)_music_largeModular {
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
		
		LWNowPlayingIndicatorProvider* imageProvider = [LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:[self musicTintColor] state:_state];
		
		if (imageProvider) {
			[template setHeaderImageProvider:imageProvider];
		}
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self musicTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_music_largeUtility {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [CLKComplicationTemplateUtilitarianLargeFlat new];
	
	CLKSimpleTextProvider* textProvider;
	LWNowPlayingIndicatorProvider* imageProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_LARGE_UTILITY", @"MUSIC")];
	} else if (_state == LWNowPlayingStatePaused) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_UTILITY", @"(PAUSED) %@"), _title]];
	} else if (_state == LWNowPlayingStatePlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		imageProvider = [LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:nil state:_state];
	}
	
	[template setTextProvider:textProvider];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_music_mediumCircular {
	if (_state != LWNowPlayingStatePlaying) {
		CLKComplicationTemplateCircularMediumSimpleImage* template = [CLKComplicationTemplateCircularMediumSimpleImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"victoryNTKMusicPaused")];
		[imageProvider setTintColor:[self musicTintColor]];
		
		[template setImageProvider:imageProvider];
		
		return template;
	} else {
		CLKComplicationTemplateCircularMediumProgressRingImage* template = [CLKComplicationTemplateCircularMediumProgressRingImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"victoryNTKMusic")];
		[template setImageProvider:imageProvider];
		
		[imageProvider setTintColor:UIColor.whiteColor];
		
		NSDate* startDate = [self _projectedStartDate];
		NSDate* endDate = [startDate dateByAddingTimeInterval:_duration];
		
		CLKRelativeDateProgressProvider* progressProvider = [CLKRelativeDateProgressProvider relativeDateProgressProviderWithStartDate:startDate endDate:endDate];
		[progressProvider setTintColor:[self musicTintColor]];
		[progressProvider setBackgroundRingAlpha:0.25];
		
		[template setProgressProvider:progressProvider];
		[template setRingStyle:0];
		
		return template;
	}
	
	return nil;
}

- (CLKComplicationTemplate*)_music_signatureBezel {
	CLKComplicationTemplateGraphicBezelCircularText* template = [CLKComplicationTemplateGraphicBezelCircularText new];
	[template setCircularTemplate:(CLKComplicationTemplateGraphicCircular*)[self _music_signatureCircular]];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_LARGE_UTILITY", @"Music")]];
	} else if (_state == LWNowPlayingStatePaused) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_UTILITY", @"(Paused) %@"), _title]]];
	} else if (_state == LWNowPlayingStatePlaying) {
		if (_artist.length) {
			[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_COMPLICATION_SIGNATURE_NOW_PLAYING_TITLE", @"%1$@ - %2$@"), _title, _artist]]];
		} else {
			[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
		}
	}
	
	return template;
}

- (CLKComplicationTemplate*)_music_signatureCircular {
	if (_state == LWNowPlayingStateNotPlaying) {
		CLKComplicationTemplateGraphicCircularImage* template = [CLKComplicationTemplateGraphicCircularImage new];
		
		CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:[NTKImageNamed(@"victoryNTKMusicPaused") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] monochromeFilterType:1 applyScalingAndCircularMasking:NO];
		[imageProvider setTintColor:[self musicTintColor]];
		
		[template setImageProvider:imageProvider];
		[template setMetadata:@{
			@"NTKRichComplicationViewBackgroundColorKey": [imageProvider.tintColor colorWithAlphaComponent:0.2]
		}];
		
		return template;
	} else if (_state == LWNowPlayingStatePaused) {
		CLKComplicationTemplateGraphicCircularClosedGaugeImage* template = [CLKComplicationTemplateGraphicCircularClosedGaugeImage new];
		
		CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:NTKImageNamed(@"victoryNTKMusic") monochromeFilterType:1 applyScalingAndCircularMasking:NO];
		[template setImageProvider:imageProvider];
		
		[template setGaugeProvider:[CLKSimpleGaugeProvider gaugeProviderWithStyle:1 gaugeColor:[self musicTintColor] fillFraction:(_elapsedTime / _duration)]];
		
		return template;
	} else if (_state == LWNowPlayingStatePlaying) {
		CLKComplicationTemplateGraphicCircularClosedGaugeImage* template = [CLKComplicationTemplateGraphicCircularClosedGaugeImage new];
		
		CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:NTKImageNamed(@"victoryNTKMusic") monochromeFilterType:1 applyScalingAndCircularMasking:NO];
		[template setImageProvider:imageProvider];
		
		NSDate* startDate = [self _projectedStartDate];
		NSDate* endDate = [startDate dateByAddingTimeInterval:_duration];
		
		[template setGaugeProvider:[CLKTimeIntervalGaugeProvider gaugeProviderWithStyle:1 gaugeColors:@[ [self musicTintColor] ] gaugeColorLocations:nil startDate:startDate endDate:endDate]];
		
		return template;
	}
	
	return nil;
}

- (CLKComplicationTemplate*)_music_signatureCorner {
	CLKComplicationTemplateGraphicCornerTextImage* template = [CLKComplicationTemplateGraphicCornerTextImage new];
	
	CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:NTKImageNamed(@"music_signature_corner") monochromeFilterType:1 applyScalingAndCircularMasking:NO];
	[imageProvider setTintColor:[self musicTintColor]];
	[template setImageProvider:imageProvider];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_LARGE_UTILITY", @"Music")]];
	} else if (_state == LWNowPlayingStatePaused) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_UTILITY", @"(Paused) %@"), _title]]];
	} else if (_state == LWNowPlayingStatePlaying) {
		if (_artist.length) {
			[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_COMPLICATION_SIGNATURE_NOW_PLAYING_TITLE", @"%1$@ - %2$@"), _title, _artist]]];
		} else {
			[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
		}
	}
	
	[template setTintColor:[self musicTintColor]];
	[template.textProvider setTintColor:[self musicTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_music_signatureRectangular {
	CLKComplicationTemplateGraphicRectangularStandardBody* template = [CLKComplicationTemplateGraphicRectangularStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_HEADER_LARGE_MODULAR", @"Music")];
		[headerTextProvider setTintColor:[self musicTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"MUSIC_STOPPED_LARGE_MODULAR", @"Tap to play music")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		[headerTextProvider setTintColor:[self musicTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		[headerTextProvider setTintColor:[self musicTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [CLKSimpleTextProvider textProviderWithText:_album];
		
		LWNowPlayingIndicatorFullColorProvider* imageProvider = [LWNowPlayingIndicatorFullColorProvider nowPlayingIndicatorFullColorProviderWithTintColor:[self musicTintColor] state:_state];
		
		if (imageProvider) {
			[template setHeaderImageProvider:imageProvider];
		}
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self musicTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_music_smallModular {
	if (_state != LWNowPlayingStatePlaying) {
		CLKComplicationTemplateModularSmallSimpleImage* template = [CLKComplicationTemplateModularSmallSimpleImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"modularSmallMusicPaused")];
		[imageProvider setTintColor:[self musicTintColor]];
		[template setImageProvider:imageProvider];
		
		return template;
	} else {
		CLKComplicationTemplateModularSmallProgressRingImage* template = [CLKComplicationTemplateModularSmallProgressRingImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"modularSmallMusic")];
		[imageProvider setTintColor:UIColor.whiteColor];
		[template setImageProvider:imageProvider];
		
		NSDate* startDate = [self _projectedStartDate];
		NSDate* endDate = [startDate dateByAddingTimeInterval:_duration];
		
		CLKRelativeDateProgressProvider* progressProvider = [CLKRelativeDateProgressProvider relativeDateProgressProviderWithStartDate:startDate endDate:endDate];
		[progressProvider setTintColor:[self musicTintColor]];
		[progressProvider setBackgroundRingAlpha:0.25];
		
		[template setProgressProvider:progressProvider];
		[template setRingStyle:0];
		
		return template;
	}
	
	return nil;
}

- (CLKComplicationTemplate*)_music_smallUtility {
	if (_state != LWNowPlayingStatePlaying) {
		CLKComplicationTemplateUtilitarianSmallSquare* template = [CLKComplicationTemplateUtilitarianSmallSquare new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"utilityCornerMusicPaused")];
		[imageProvider setTintColor:[self musicTintColor]];
		[template setImageProvider:imageProvider];
		
		return template;
	} else {
		CLKComplicationTemplateUtilitarianSmallProgressRingImage* template = [CLKComplicationTemplateUtilitarianSmallProgressRingImage new];
		
		CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"utilityCornerMusic")];
		[imageProvider setTintColor:UIColor.whiteColor];
		[template setImageProvider:imageProvider];
		
		NSDate* startDate = [self _projectedStartDate];
		NSDate* endDate = [startDate dateByAddingTimeInterval:_duration];
		
		CLKRelativeDateProgressProvider* progressProvider = [CLKRelativeDateProgressProvider relativeDateProgressProviderWithStartDate:startDate endDate:endDate];
		[progressProvider setTintColor:[self musicTintColor]];
		[progressProvider setBackgroundRingAlpha:0.25];
		
		[template setProgressProvider:progressProvider];
		[template setRingStyle:0];
		
		return template;
	}
	
	return nil;
}

#pragma mark - Now Playing

- (CLKComplicationTemplate*)_nowPlaying_largeModular {
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
		
		LWNowPlayingIndicatorProvider* imageProvider = [LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:[self nowPlayingTintColor] state:_state];
		
		if (imageProvider) {
			[template setHeaderImageProvider:imageProvider];
		}
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self nowPlayingTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_nowPlaying_largeUtility {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [CLKComplicationTemplateUtilitarianLargeFlat new];
	
	if (_state > LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
		[template setImageProvider:[LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:[self nowPlayingTintColor] state:_state]];
	} else {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_UTILITY", @"TAP TO OPEN")]];
	}
	
	return template;
}

- (CLKComplicationTemplate*)_nowPlaying_signatureRectangular {
	CLKComplicationTemplateGraphicRectangularStandardBody* template = [CLKComplicationTemplateGraphicRectangularStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	CLKSimpleTextProvider* body2TextProvider;
	
	if (_state != LWNowPlayingStatePlaying) {
		if (_state != LWNowPlayingStatePaused) {
			if (_state == LWNowPlayingStateNotPlaying) {
				headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_HEADER_LARGE_MODULAR", @"Now Playing")];
				[headerTextProvider setTintColor:[self nowPlayingTintColor]];
				
				body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"NOW_PLAYING_STOPPED_LARGE_MODULAR", @"Tap to open")];
			}
		} else {
			headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
			[headerTextProvider setTintColor:[self nowPlayingTintColor]];
			
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
		[headerTextProvider setTintColor:[self nowPlayingTintColor]];
		
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
		
		[template setHeaderImageProvider:[LWNowPlayingIndicatorFullColorProvider nowPlayingIndicatorFullColorProviderWithTintColor:[self nowPlayingTintColor] state:_state]];
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self nowPlayingTintColor]];
	
	return template;
}

#pragma mark - Podcasts

- (CLKComplicationTemplate*)_podcast_extraLarge {
	CLKComplicationTemplateExtraLargeSimpleImage* template = [CLKComplicationTemplateExtraLargeSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"XLPodcast")];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_largeModular {
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
		
		// LWNowPlayingIndicatorProvider* imageProvider = [LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:PODCAST_TINT_COLOR state:_state];
		
		// if (imageProvider) {
		// 	[template setHeaderImageProvider:imageProvider];
		// }
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self podcastTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_largeUtility {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [CLKComplicationTemplateUtilitarianLargeFlat new];
	
	CLKSimpleTextProvider* textProvider;
	LWNowPlayingIndicatorProvider* imageProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_STOPPED_LARGE_UTILITY", @"PODCASTS")];
	} else if (_state == LWNowPlayingStatePaused) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"PODCAST_PAUSED_LARGE_UTILITY", @"(PAUSED) %@"), _title]];
	} else if (_state == LWNowPlayingStatePlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		imageProvider = [LWNowPlayingIndicatorProvider nowPlayingIndicatorProviderWithTintColor:nil state:_state];
	}
	
	[template setTextProvider:textProvider];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_mediumCircular {
	CLKComplicationTemplateCircularMediumSimpleImage* template = [CLKComplicationTemplateCircularMediumSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"VictoryDigitalPodcast")];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_signatureBezel {
	CLKComplicationTemplateGraphicBezelCircularText* template = [CLKComplicationTemplateGraphicBezelCircularText new];
	[template setCircularTemplate:(CLKComplicationTemplateGraphicCircular*)[self _podcast_signatureCircular]];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_STOPPED_LARGE_UTILITY", @"PODCAST")]];
	} else if (_state == LWNowPlayingStatePaused) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"MUSIC_PAUSED_LARGE_UTILITY", @"(Paused) %@"), _title]]];
	} else if (_state == LWNowPlayingStatePlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
	}
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_signatureCircular {
	CLKComplicationTemplateGraphicCircularImage* template = [CLKComplicationTemplateGraphicCircularImage new];
	
	CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:[NTKImageNamed(@"VictoryDigitalPodcast") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] monochromeFilterType:1 applyScalingAndCircularMasking:NO];
	[imageProvider setTintColor:[self podcastTintColor]];
	
	[template setImageProvider:imageProvider];
	[template setMetadata:@{
		@"NTKRichComplicationViewBackgroundColorKey": [imageProvider.tintColor colorWithAlphaComponent:0.2]
	}];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_signatureCorner {
	CLKComplicationTemplateGraphicCornerTextImage* template = [CLKComplicationTemplateGraphicCornerTextImage new];
	
	CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:NTKImageNamed(@"GraphicCornerPodcast") monochromeFilterType:1 applyScalingAndCircularMasking:NO];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_STOPPED_LARGE_UTILITY", @"PODCASTS")]];
	} else  {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
	}
	
	[template setTintColor:[self podcastTintColor]];
	[template.textProvider setTintColor:[self podcastTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_signatureRectangular {
	CLKComplicationTemplateGraphicRectangularStandardBody* template = [CLKComplicationTemplateGraphicRectangularStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_STOPPED_HEADER_LARGE_MODULAR", @"Podcasts")];
		[headerTextProvider setTintColor:[self podcastTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"PODCAST_LARGE_MODULAR", @"Tap to play podcasts")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		[headerTextProvider setTintColor:[self podcastTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"PODCAST_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		[headerTextProvider setTintColor:[self podcastTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		
		LWNowPlayingIndicatorFullColorProvider* imageProvider = [LWNowPlayingIndicatorFullColorProvider nowPlayingIndicatorFullColorProviderWithTintColor:[self podcastTintColor] state:_state];
		
		if (imageProvider) {
			[template setHeaderImageProvider:imageProvider];
		}
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self podcastTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_smallCircular {
	CLKComplicationTemplateCircularSmallSimpleImage* template = [CLKComplicationTemplateCircularSmallSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"ColorPodcast")];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_smallModular {
	CLKComplicationTemplateModularSmallSimpleImage* template = [CLKComplicationTemplateModularSmallSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"ModularSmallPodcast")];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_podcast_smallUtility {
	CLKComplicationTemplateUtilitarianSmallSquare* template = [CLKComplicationTemplateUtilitarianSmallSquare new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"UtilityCornerPodcast")];
	[imageProvider setTintColor:[self podcastTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

#pragma mark - Radio

- (CLKComplicationTemplate*)_radio_extraLarge {
	CLKComplicationTemplateExtraLargeSimpleImage* template = [CLKComplicationTemplateExtraLargeSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"XLRadio")];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_largeModular {
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
	
	[template setTintColor:[self radioTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_largeUtility {
	CLKComplicationTemplateUtilitarianLargeFlat* template = [CLKComplicationTemplateUtilitarianLargeFlat new];
	
	CLKSimpleTextProvider* textProvider;
	LWNowPlayingIndicatorProvider* imageProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_STOPPED_LARGE_UTILITY", @"RADIO")];
	} else if (_state == LWNowPlayingStatePaused) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"RADIO_PAUSED_LARGE_UTILITY", @"(PAUSED) %@"), _title]];
	} else if (_state == LWNowPlayingStatePlaying) {
		textProvider = [CLKSimpleTextProvider textProviderWithText:_title];
	}
	
	[template setTextProvider:textProvider];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_mediumCircular {
	CLKComplicationTemplateCircularMediumSimpleImage* template = [CLKComplicationTemplateCircularMediumSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"VictoryDigitalRadio")];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_signatureBezel {
	CLKComplicationTemplateGraphicBezelCircularText* template = [CLKComplicationTemplateGraphicBezelCircularText new];
	[template setCircularTemplate:(CLKComplicationTemplateGraphicCircular*)[self _radio_signatureCircular]];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_STOPPED_LARGE_UTILITY", @"RADIO")]];
	} else if (_state == LWNowPlayingStatePaused) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:NTKClockFaceLocalizedString(@"RADIO_PAUSED_LARGE_UTILITY", @"(Paused) %@"), _title]]];
	} else if (_state == LWNowPlayingStatePlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
	}
	
	return template;
}

- (CLKComplicationTemplate*)_radio_signatureCircular {
	CLKComplicationTemplateGraphicCircularImage* template = [CLKComplicationTemplateGraphicCircularImage new];
	
	CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:[NTKImageNamed(@"GraphicCircularRadio") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] monochromeFilterType:1 applyScalingAndCircularMasking:NO];
	[imageProvider setTintColor:[self radioTintColor]];
	
	[template setImageProvider:imageProvider];
	[template setMetadata:@{
		@"NTKRichComplicationViewBackgroundColorKey": [imageProvider.tintColor colorWithAlphaComponent:0.2]
	}];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_signatureCorner {
	CLKComplicationTemplateGraphicCornerTextImage* template = [CLKComplicationTemplateGraphicCornerTextImage new];
	
	CLKFullColorImageProvider* imageProvider = [CLKFullColorImageProvider providerWithFullColorImage:NTKImageNamed(@"GraphicCornerRadio") monochromeFilterType:1 applyScalingAndCircularMasking:NO];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	if (_state == LWNowPlayingStateNotPlaying) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_STOPPED_LARGE_UTILITY", @"RADIO")]];
	} else  {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:_title]];
	}
	
	[template setTintColor:[self radioTintColor]];
	[template.textProvider setTintColor:[self radioTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_signatureRectangular {
	CLKComplicationTemplateGraphicRectangularStandardBody* template = [CLKComplicationTemplateGraphicRectangularStandardBody new];
	
	CLKSimpleTextProvider* headerTextProvider;
	CLKSimpleTextProvider* body1TextProvider;
	NTKOverrideTextProvider* body2TextProvider;
	
	if (_state == LWNowPlayingStateNotPlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_STOPPED_HEADER_LARGE_MODULAR", @"Radio")];
		[headerTextProvider setTintColor:[self radioTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:NTKClockFaceLocalizedString(@"RADIO_LARGE_MODULAR", @"Tap to play radio")];
	} else if (_state == LWNowPlayingStatePaused) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		[headerTextProvider setTintColor:[self radioTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [self _italicTextProviderForText:NTKClockFaceLocalizedString(@"RADIO_PAUSED_LARGE_MODULAR", @"Paused")];
	} else if (_state == LWNowPlayingStatePlaying) {
		headerTextProvider = [CLKSimpleTextProvider textProviderWithText:_title];
		[headerTextProvider setTintColor:[self radioTintColor]];
		
		body1TextProvider = [CLKSimpleTextProvider textProviderWithText:_artist];
		body2TextProvider = [CLKSimpleTextProvider textProviderWithText:_album];
		
		LWNowPlayingIndicatorFullColorProvider* imageProvider = [LWNowPlayingIndicatorFullColorProvider nowPlayingIndicatorFullColorProviderWithTintColor:[self radioTintColor] state:_state];
		
		if (imageProvider) {
			[template setHeaderImageProvider:imageProvider];
		}
	}
	
	[template setHeaderTextProvider:headerTextProvider];
	[template setBody1TextProvider:body1TextProvider];
	
	if (body2TextProvider) {
		[template setBody2TextProvider:body2TextProvider];
	}
	
	[template setTintColor:[self radioTintColor]];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_smallCircular {
	CLKComplicationTemplateCircularSmallSimpleImage* template = [CLKComplicationTemplateCircularSmallSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"ColorRadio")];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_smallModular {
	CLKComplicationTemplateModularSmallSimpleImage* template = [CLKComplicationTemplateModularSmallSimpleImage new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"ModularSmallRadio")];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

- (CLKComplicationTemplate*)_radio_smallUtility {
	CLKComplicationTemplateUtilitarianSmallSquare* template = [CLKComplicationTemplateUtilitarianSmallSquare new];
	
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:NTKImageNamed(@"UtilityCornerRadio")];
	[imageProvider setTintColor:[self radioTintColor]];
	[template setImageProvider:imageProvider];
	
	return template;
}

@end