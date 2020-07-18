//
// LWOPhysicalSyncController.m
// LockWatch
//
// Created by janikschmidt on 7/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NTKPersistentFaceCollection.h>

#import "LWOPhysicalSyncController.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWPersistentFaceCollection.h"

@implementation LWOPhysicalSyncController

#pragma mark - Instance Methods

- (void)syncFaces {
	LWEmulatedCLKDevice* device = [NSClassFromString(@"LWEmulatedCLKDevice") currentDevice];
	
	if (device && device.physicalDevice) {
		NTKPersistentFaceCollection* collection = [[NTKPersistentFaceCollection alloc] initWithCollectionIdentifier:@"LibraryFaces" deviceUUID:[device.physicalDevice nrDeviceUUID]];
		[collection addObserver:self];
	}
}

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	[super buttonTapped:button];
	
	if (button == self.primaryTrayButton) {
		[self syncFaces];
	} else if (button == self.secondaryTrayButton) {
		[self.flowItemDelegate moveToFlowItem:[self nextFlowItem] animated:YES];
	}
}

#pragma mark - NTKFaceCollectionObserver

- (void)faceCollectionDidLoad:(NTKFaceCollection *)collection {
	LWEmulatedCLKDevice* device = [NSClassFromString(@"LWEmulatedCLKDevice") currentDevice];
	
	LWPersistentFaceCollection* _libraryFaceCollection = [[NSClassFromString(@"LWPersistentFaceCollection") alloc] initWithCollectionIdentifier:@"LibraryFaces" forDevice:device.physicalDevice JSONObjectRepresentation:collection.JSONObjectRepresentation];
	[_libraryFaceCollection synchronize];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"ml.festival.lockwatch2/WatchSelected", NULL, NULL, YES);
}

@end