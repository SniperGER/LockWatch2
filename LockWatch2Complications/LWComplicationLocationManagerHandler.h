//
// LWComplicationLocationManagerHandler.h
// LockWatch
//
// Created by janikschmidt on 8/15/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWComplicationLocationManagerHandler : NSObject

@property (nonatomic) BOOL wantsGroundLocation;
@property (copy, nonatomic) void (^handler)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error);

- (instancetype)initWithHandler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler;
- (instancetype)initWithWantsGroundLocation:(BOOL)wantsGroundLocation handler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler;

@end

NS_ASSUME_NONNULL_END