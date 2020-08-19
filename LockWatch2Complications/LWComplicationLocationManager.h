//
// LWComplicationLocationManager.h
// LockWatch
//
// Created by janikschmidt on 8/15/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <CoreLocation/CoreLocation.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "LWComplicationLocationManagerHandler.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LWComplicationLocationManagerState) {
/*  0 */	LWComplicationLocationManagerStateIdle,
/*  1 */	LWComplicationLocationManagerStatePreparing,
/*  2 */	LWComplicationLocationManagerStateReady,
/*  3 */	LWComplicationLocationManagerStateMonitoring
};

@class CLInUseAssertion;

@interface LWComplicationLocationManager : NTKLocationManager <CLLocationManagerDelegate> {
	CLLocation* _currentLocation;
	CLLocation* _previousLocation;
	NSUInteger _handlerCounter;
	LWComplicationLocationManagerState _state;
	NSMutableDictionary<NSString*, LWComplicationLocationManagerHandler*>* _locationUpdateHandlers;
	CLLocationManager* _locationManager;
	CLInUseAssertion *_locationInUseAssertion;
    NSObject<OS_dispatch_queue>* _queue;
    NSDate* _lastLocationUpdateDate;
    NSLock* _locationAccessLock;
    NSLock* _tokenAccessLock;
}

@property (nonatomic, readonly) CLLocation* currentLocation;
@property (nonatomic, readonly) CLLocation* previousLocation;

@end

NS_ASSUME_NONNULL_END