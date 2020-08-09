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

@end

NS_ASSUME_NONNULL_END