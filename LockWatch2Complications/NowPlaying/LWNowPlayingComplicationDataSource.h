//
// LWNowPlayingComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 4/4/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"
#import "LWNowPlayingTimelineEntry.h"

NS_ASSUME_NONNULL_BEGIN

@class CLKComplicationTimelineEntry, LWNowPlayingTimelineEntry;

@interface LWNowPlayingComplicationDataSource : LWComplicationDataSourceBase {
	LWNowPlayingState _nowPlayingState;
	NSDictionary* _nowPlayingInfo;
	NSString* _applicationName;
    CLKComplicationTimelineEntry* _nowPlayingEntry;
    NSNumber* _activeOriginIdentifier;
    BOOL _isPaused;
    BOOL _needsInvalidation;
}

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (CLKComplicationTimelineEntry*)_defaultTimelineEntry;
- (void)_updateTimelineEntry;
- (void)_invalidateIfNecessary;
- (void)mediaRemoteDidUpdateNowPlayingApplication:(NSNotification*)notification;
- (void)mediaRemoteDidUpdateNowPlayingInfo:(NSNotification*)notification;
- (void)mediaRemoteDidUpdatePlaybackState:(NSNotification*)notification;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END