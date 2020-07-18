//
// LWODeviceTypeSelectionController.m
// LockWatch
//
// Created by janikschmidt on 7/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoRegistry/NRDevice.h>

#import "LWODeviceTypeSelectionController.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWPreferences.h"

extern NSString* LWOLocalizedString(NSString* key, NSString* value);

@implementation LWODeviceTypeSelectionController

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		LWEmulatedCLKDevice* device = [NSClassFromString(@"LWEmulatedCLKDevice") currentDevice];
		if (device && device.physicalDevice) {
			[cell.textLabel setText:[NSString stringWithFormat:LWOLocalizedString(@"ONBOARDING_DEVICE_PHYSICAL", nil), [[device.physicalDevice nrDevice] valueForProperty:@"name"]]];
		} else {
			[cell.textLabel setText:LWOLocalizedString(@"ONBOARDING_DEVICE_PHYSICAL_NOT_AVAILABLE", nil)];
			[cell.textLabel setEnabled:NO];
			[cell setUserInteractionEnabled:NO];
		}
	}
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSClassFromString(@"LWPreferences") sharedInstance] setIsEmulatingDevice:(indexPath.row == 1)];
	[[NSClassFromString(@"LWPreferences") sharedInstance] synchronize];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"ml.festival.lockwatch2/WatchSelected", NULL, NULL, YES);
	
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end