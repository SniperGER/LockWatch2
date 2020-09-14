//
// LWPreferences.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

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
	
	if (![_defaults.allKeys containsObject:@"backgroundType"]) {
		[_defaults setObject:@(1) forKey:@"backgroundType"];
	}
	_backgroundType = [[_defaults objectForKey:@"backgroundType"] integerValue];
	
	if (![_defaults.allKeys containsObject:@"batteryChargingViewHidden"]) {
		[_defaults setObject:@YES forKey:@"batteryChargingViewHidden"];
	}
	_batteryChargingViewHidden = [[_defaults objectForKey:@"batteryChargingViewHidden"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"complicationContent"]) {
		[_defaults setObject:@2 forKey:@"complicationContent"];
	}
	_complicationContent = [[_defaults objectForKey:@"complicationContent"] integerValue];
	
	
	
	if (![_defaults.allKeys containsObject:@"horizontalOffsetPortrait"]) {
		[_defaults setObject:@0.0 forKey:@"horizontalOffsetPortrait"];
	}
	_horizontalOffsetPortrait = [[_defaults objectForKey:@"horizontalOffsetPortrait"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"verticalOffsetPortrait"]) {
		[_defaults setObject:@0.0 forKey:@"verticalOffsetPortrait"];
	}
	_verticalOffsetPortrait = [[_defaults objectForKey:@"verticalOffsetPortrait"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"scalePortrait"]) {
		[_defaults setObject:@1.0 forKey:@"scalePortrait"];
	}
	_scalePortrait = [[_defaults objectForKey:@"scalePortrait"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"horizontalOffsetLandscape"]) {
		[_defaults setObject:@0.0 forKey:@"horizontalOffsetLandscape"];
	}
	_horizontalOffsetLandscape = [[_defaults objectForKey:@"horizontalOffsetLandscape"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"verticalOffsetLandscape"]) {
		[_defaults setObject:@0.0 forKey:@"verticalOffsetLandscape"];
	}
	_verticalOffsetLandscape = [[_defaults objectForKey:@"verticalOffsetLandscape"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"scaleLandscape"]) {
		[_defaults setObject:@1.0 forKey:@"scaleLandscape"];
	}
	_scaleLandscape = [[_defaults objectForKey:@"scaleLandscape"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"verticalOffsetLandscapePhone"]) {
		[_defaults setObject:@0.0 forKey:@"verticalOffsetLandscapePhone"];
	}
	_verticalOffsetLandscapePhone = [[_defaults objectForKey:@"verticalOffsetLandscapePhone"] floatValue];
	
	if (![_defaults.allKeys containsObject:@"scaleLandscapePhone"]) {
		[_defaults setObject:@1.0 forKey:@"scaleLandscapePhone"];
	}
	_scaleLandscapePhone = [[_defaults objectForKey:@"scaleLandscapePhone"] floatValue];
	
	
	
	if (![_defaults.allKeys containsObject:@"onBoardingCompleted"]) {
		[_defaults setObject:@NO forKey:@"onBoardingCompleted"];
	}
	_onBoardingCompleted = [[_defaults objectForKey:@"onBoardingCompleted"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"upgradeLastVersion"]) {
		[_defaults setObject:@"" forKey:@"upgradeLastVersion"];
	}
	_upgradeLastVersion = [_defaults objectForKey:@"upgradeLastVersion"];
	
	
	
	if (![_defaults.allKeys containsObject:@"showCase"]) {
		[_defaults setObject:@NO forKey:@"showCase"];
	}
	_showCase = [[_defaults objectForKey:@"showCase"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"showBand"]) {
		[_defaults setObject:@NO forKey:@"showBand"];
	}
	_showBand = [[_defaults objectForKey:@"showBand"] boolValue];
	
	if (![_defaults.allKeys containsObject:@"caseImageNames"]) {
		[_defaults setObject:@{
			@"394h": @"case-aluminum-spacegray_394h",
			@"448h": @"case-aluminum-spacegray_448h"
		} forKey:@"caseImageNames"];
	}
	_caseImageNames = [_defaults objectForKey:@"caseImageNames"];
	
	if (![_defaults.allKeys containsObject:@"bandImageNames"]) {
		[_defaults setObject:@{
			@"394h": @"sport-black_compact",
			@"448h": @"sport-black_regular"
		} forKey:@"bandImageNames"];
	}
	_bandImageNames = [_defaults objectForKey:@"bandImageNames"];
}

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	[_defaults setObject:@(enabled) forKey:@"enabled"];
}

- (void)setIsEmulatingDevice:(BOOL)isEmulatingDevice {
	_isEmulatingDevice = isEmulatingDevice;
	[_defaults setObject:@(isEmulatingDevice) forKey:@"isEmulatingDevice"];
}

- (void)setEmulatedDeviceType:(NSString*)emulatedDeviceType {
	_emulatedDeviceType = emulatedDeviceType;
	[_defaults setObject:emulatedDeviceType forKey:@"emulatedDeviceType"];
}

- (void)setBackgroundType:(NSInteger)backgroundType {
	_backgroundType = backgroundType;
	[_defaults setObject:@(backgroundType) forKey:@"backgroundType"];
}

- (void)setBatteryChargingViewHidden:(BOOL)batteryChargingViewHidden {
	_batteryChargingViewHidden = batteryChargingViewHidden;
	[_defaults setObject:@(batteryChargingViewHidden) forKey:@"batteryChargingViewHidden"];
}

- (void)setComplicationContent:(LWComplicationContentType)complicationContent {
	_complicationContent = complicationContent;
	[_defaults setObject:@(complicationContent) forKey:@"complicationContent"];
}


- (void)setOnBoardingCompleted:(BOOL)onBoardingCompleted {
	_onBoardingCompleted = onBoardingCompleted;
	[_defaults setObject:@(onBoardingCompleted) forKey:@"onBoardingCompleted"];
}

- (void)setUpgradeLastVersion:(NSString*)upgradeLastVersion {
	_upgradeLastVersion = upgradeLastVersion;
	[_defaults setObject:upgradeLastVersion forKey:@"upgradeLastVersion"];
}


- (BOOL)synchronize {
	return [_defaults writeToURL:[NSURL fileURLWithPath:PREFERENCES_PATH] error:nil];
}

@end