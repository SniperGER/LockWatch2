//
// LWNowPlayingComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 4/4/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <MediaRemote/MediaRemote.h>

#import "LWNowPlayingComplicationDataSource.h"

#if __cplusplus
extern "C" {
#endif

typedef void (^MRMediaRemoteGetNowPlayingApplicationDisplayNameCompletion)(CFStringRef displayName);
void MRMediaRemoteGetNowPlayingApplicationDisplayName(id origin, dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationDisplayNameCompletion completion);

extern CFStringRef kMRMediaRemoteNowPlayingApplicationDidChangeNotification;
extern CFStringRef kMRMediaRemoteNowPlayingApplicationDisplayNameUserInfoKey;
extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
extern CFStringRef kMRMediaRemoteNowPlayingInfoDidChangeNotification;
extern CFStringRef kMRMediaRemoteNowPlayingInfoPlaybackRate;

#if __cplusplus
}
#endif

@implementation LWNowPlayingComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_isPaused = NO;
		_needsInvalidation = NO;
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaRemoteDidUpdateNowPlayingApplication:) name:(__bridge NSString*)kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaRemoteDidUpdateNowPlayingInfo:) name:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaRemoteDidUpdatePlaybackState:) name:(__bridge NSString*)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_defaultTimelineEntry {
	static NTKTimelineEntryModel* timelineEntry = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timelineEntry = [[LWNowPlayingTimelineEntry alloc] initAsSwitcherTemplate];
    });

    return [timelineEntry entryForComplicationFamily:self.family];
}

- (void)_updateTimelineEntry {
	dispatch_async(dispatch_get_main_queue(), ^{
		LWNowPlayingTimelineEntry* timelineEntry = [[LWNowPlayingTimelineEntry alloc] initWithState:_nowPlayingState nowPlayingInfo:_nowPlayingInfo applicationName:_applicationName];
		_nowPlayingEntry = [timelineEntry entryForComplicationFamily:self.family];
		
		_needsInvalidation = YES;
		if (!_isPaused) {
			[self _invalidateIfNecessary];
		}
	});
}

- (void)_invalidateIfNecessary {
	if (_needsInvalidation) {
		[self.delegate invalidateSwitcherTemplate];
		[self.delegate invalidateEntries];
		
		_needsInvalidation = NO;
	}
}

- (void)mediaRemoteDidUpdateNowPlayingApplication:(NSNotification*)notification {
	MRMediaRemoteGetNowPlayingApplicationDisplayName(NULL, dispatch_get_main_queue(), ^(CFStringRef displayName) {
		_applicationName = (__bridge NSString*)displayName;
		
		[self _updateTimelineEntry];
	});
}

- (void)mediaRemoteDidUpdateNowPlayingInfo:(NSNotification*)notification {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef nowPlayingInfo) {
		_nowPlayingInfo = (__bridge NSDictionary*)nowPlayingInfo;
		
		if (!_nowPlayingInfo) {
			_nowPlayingState = LWNowPlayingStateNotPlaying;
		} else if (_nowPlayingState == LWNowPlayingStateNotPlaying && [_nowPlayingInfo objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoPlaybackRate]) {
			_nowPlayingState = [_nowPlayingInfo[(__bridge NSString*)kMRMediaRemoteNowPlayingInfoPlaybackRate] integerValue] + 1;
		} else {
			_nowPlayingState = LWNowPlayingStatePlaying;
		}
		
		[self _updateTimelineEntry];
	});
}

- (void)mediaRemoteDidUpdatePlaybackState:(NSNotification*)notification {
	MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
		_nowPlayingState = _nowPlayingInfo ? isPlaying + 1 : LWNowPlayingStateNotPlaying;
		
		[self _updateTimelineEntry];
	});
}

- (void)pause {
	_isPaused = YES;
}

- (void)resume {
	_isPaused = NO;
	
	[self _invalidateIfNecessary];
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	if (_nowPlayingEntry) {
		return [_nowPlayingEntry complicationTemplate];
	} else {
		return [[self _defaultTimelineEntry] complicationTemplate];
	}
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	if (_nowPlayingEntry) {
		handler(_nowPlayingEntry);
	} else {
		handler([self _defaultTimelineEntry]);
	}
}

@end