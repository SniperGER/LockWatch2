//
// LWRadioComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/8/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <MediaPlayerUI/MediaPlayerUI.h>

#import "LWComplicationDataSourceBase.h"
#import "../LWNowPlayingTimelineEntry.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTimelineEntry, MPUNowPlayingController;

@interface LWRadioComplicationDataSource : LWComplicationDataSourceBase <MPUNowPlayingDelegate> {
	MPUNowPlayingController* _nowPlayingController;
	CLKComplicationTimelineEntry* _nowPlayingEntry;
	NSString* _activeOriginIdentifier;
	NSString* _activeOriginDisplayName;
	BOOL _needsInvalidation;
	BOOL _isPaused;
	NSObject<OS_dispatch_queue>* _queue;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (id)description;
- (CLKComplicationTimelineEntry*)_defaultTimelineEntry;
- (void)_invalidateIfNeeded;
- (LWNowPlayingState)_nowPlayingState;
- (void)_updateWithOrigin:(id)origin;

@end

NS_ASSUME_NONNULL_END