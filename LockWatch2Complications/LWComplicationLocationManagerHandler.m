//
// LWComplicationLocationManagerHandler.m
// LockWatch
//
// Created by janikschmidt on 8/15/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationLocationManagerHandler.h"

@implementation LWComplicationLocationManagerHandler

- (instancetype)initWithHandler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler {
	return [self initWithWantsGroundLocation:NO handler:handler];
}

- (instancetype)initWithWantsGroundLocation:(BOOL)wantsGroundLocation handler:(void (^)(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error))handler {
	if (self = [super init]) {
		_handler = handler;
		_wantsGroundLocation = wantsGroundLocation;
	}
	
	return self;
}

@end