//
// LWAstronomyComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@class CLLocation;

@interface LWAstronomyComplicationDataSource : LWComplicationDataSourceBase {
	NSString* _token;
	CLLocation* _currentLocation;
	CLLocation* _anyLocation;
	NSUInteger _vista;
	BOOL _listeningForNotifications;
}

- (instancetype)initWithComplication:(NTKAstronomyComplication*)complication family:(long long)family forDevice:(CLKDevice*)device;
- (void)dealloc;
- (CLKComplicationTimelineEntry*)_currentTimelineEntryWithIdealizedDate:(BOOL)idealizedDate;
- (void)_invalidate;
- (void)_handleLocationUpdate:(CLLocation*)currentLocation anyLocation:(CLLocation*)anyLocation;
- (void)_startObserving;
- (void)_stopObserving;

@end

NS_ASSUME_NONNULL_END