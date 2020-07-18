//
// FSVLOBSetupFinishedController.m
// LockWatch
//
// Created by janikschmidt on 7/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBSetupFinishedController.h"

@implementation FSVLOBSetupFinishedController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationItem setHidesBackButton:YES animated:YES];
}

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	if (button == self.primaryTrayButton) {
		[self.flowItemDelegate dismissWithSetupCompletionState:YES];
	}
}

- (NSString*)nextFlowItem {
	return nil;
}

@end