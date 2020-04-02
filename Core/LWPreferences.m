//
// LWPreferences.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"

#import "LWPreferences.h"

@implementation LWPreferences

+ (instancetype)sharedInstance {
    static LWPreferences* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LWPreferences alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		[self reloadPreferences];
		[self synchronize];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)reloadPreferences {
	_defaults = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	if (!_defaults) {
		_defaults = [NSMutableDictionary dictionary];
	}
	
	if (![_defaults.allKeys containsObject:@"enabled"]) {
		[_defaults setObject:@YES forKey:@"enabled"];
	}
	_enabled = [[_defaults objectForKey:@"enabled"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"isEmulatingDevice"]) {
		[_defaults setObject:@YES forKey:@"isEmulatingDevice"];
	}
	_isEmulatingDevice = [[_defaults objectForKey:@"isEmulatingDevice"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"emulatedDeviceType"]) {
		[_defaults setObject:@"Watch5,4" forKey:@"emulatedDeviceType"];
	}
	_emulatedDeviceType = [_defaults objectForKey:@"emulatedDeviceType"];
	
	if (![_defaults.allKeys containsObject:@"backgroundEnabled"]) {
		[_defaults setObject:@YES forKey:@"backgroundEnabled"];
	}
	_backgroundEnabled = [[_defaults objectForKey:@"backgroundEnabled"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"batteryChargingViewHidden"]) {
		[_defaults setObject:@YES forKey:@"batteryChargingViewHidden"];
	}
	_batteryChargingViewHidden = [[_defaults objectForKey:@"batteryChargingViewHidden"] boolValue];
}

- (BOOL)synchronize {
	return [_defaults writeToFile:PREFERENCES_PATH atomically:YES];
}

@end