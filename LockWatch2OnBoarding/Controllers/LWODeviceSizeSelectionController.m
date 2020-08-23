//
// LWODeviceSizeSelectionController.m
// LockWatch
//
// Created by janikschmidt on 7/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWODeviceSizeSelectionController.h"

#import "Core/LWPreferences.h"

@implementation LWODeviceSizeSelectionController

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	[super buttonTapped:button];
	
	LWPreferences* preferences = [NSClassFromString(@"LWPreferences") sharedInstance];
	
	if (self.leftContainer.isSelected) {
		[preferences setEmulatedDeviceType:self.leftContainer.value];
	} else if (self.rightContainer.isSelected) {
		[preferences setEmulatedDeviceType:self.rightContainer.value];
	}
	
	[preferences synchronize];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"ml.festival.lockwatch2/WatchSelected", NULL, NULL, YES);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ml.festival.lockwatch2/ResetLibrary" object:nil userInfo:nil];
}

@end