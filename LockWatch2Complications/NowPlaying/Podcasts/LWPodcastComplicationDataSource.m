//
// LWPodcastComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/8/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWPodcastComplicationDataSource.h"

#import "LWPodcastComplicationDataSource.h"

extern NSString* CLKStringForComplicationFamily(long long family);

@implementation LWPodcastComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_queue = dispatch_queue_create("com.apple.NanoTimeKit.NTKPodcastComplicationDataSource", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0));
		
		_needsInvalidation = NO;
		_isPaused = YES;
		
		_nowPlayingController = [MPUNowPlayingController new];
		[_nowPlayingController setDelegate:self];
	}
	
	return self;
}

- (id)description {
	return [NSString stringWithFormat:@"%@[%@]", [super description], CLKStringForComplicationFamily(self.family)];
}

#pragma mark - Instance Methods

- (CLKComplicationTimelineEntry*)_defaultTimelineEntry {
	LWNowPlayingTimelineEntry* timelineEntry = [[LWNowPlayingTimelineEntry alloc] initAsSwitcherTemplate];;
	CLKComplicationTimelineEntry* defaultTimelineEntry = [CLKComplicationTimelineEntry entryWithDate:timelineEntry.entryDate complicationTemplate:[timelineEntry podcastTemplateForComplicationFamily:self.family]];

    return defaultTimelineEntry;
}

- (void)_invalidateIfNeeded {
	if (_needsInvalidation) {
		[self.delegate invalidateEntriesWithTritiumUpdatePriority:1];
		[self.delegate invalidateSwitcherTemplate];
		
		_needsInvalidation = NO;
	}
}

- (LWNowPlayingState)_nowPlayingState {
	if ([[_nowPlayingController nowPlayingAppDisplayID] isEqualToString:@"com.apple.podcasts"] && [_nowPlayingController currentNowPlayingAppIsRunning] && _nowPlayingController.currentNowPlayingMetadata.nowPlayingInfo != nil) {
		if ([_nowPlayingController isPlaying]) return LWNowPlayingStatePlaying;
		
		return LWNowPlayingStatePaused;
	}
	
	return LWNowPlayingStateNotPlaying;
}

- (void)_updateWithOrigin:(id)origin {
	dispatch_async(_queue, ^{
		_activeOriginIdentifier = origin;
		
		CLKComplicationTimelineEntry* defaultTimelineEntry = [CLKComplicationTimelineEntry new];
		LWNowPlayingTimelineEntry* timelineEntry = [[LWNowPlayingTimelineEntry alloc] initWithState:[self _nowPlayingState] nowPlayingController:_nowPlayingController applicationDisplayName:_activeOriginDisplayName];
		
		[defaultTimelineEntry setDate:[timelineEntry entryDate]];
		[defaultTimelineEntry setComplicationTemplate:[timelineEntry podcastTemplateForComplicationFamily:self.family]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_nowPlayingEntry = defaultTimelineEntry;
			
			_needsInvalidation = YES;
			
			if (!_isPaused) {
				[self _invalidateIfNeeded];
			}
		});
	});
}

#pragma mark - MPUNowPlayingDelegate

- (void)nowPlayingController:(MPUNowPlayingController*)nowPlayingController nowPlayingApplicationDidChange:(id)nowPlayingApplication {
	[self _updateWithOrigin:[nowPlayingController nowPlayingAppDisplayID]];
}

- (void)nowPlayingController:(MPUNowPlayingController*)nowPlayingController nowPlayingInfoDidChange:(id)nowPlayingInfo {
	[self _updateWithOrigin:[nowPlayingController nowPlayingAppDisplayID]];
}

- (void)nowPlayingController:(MPUNowPlayingController*)nowPlayingController playbackStateDidChange:(BOOL)playbackState {
	[self _updateWithOrigin:[nowPlayingController nowPlayingAppDisplayID]];
}

#pragma mark - NTKComplicationDataSource

- (void)becomeActive {
	[self _updateWithOrigin:[_nowPlayingController nowPlayingAppDisplayID]];
}

- (id)complicationApplicationIdentifier {
	return @"com.apple.podcasts";
}

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

- (void)pause {
	_isPaused = YES;
}

- (void)resume {
	_isPaused = NO;
	
	[self _invalidateIfNeeded];
}

@end