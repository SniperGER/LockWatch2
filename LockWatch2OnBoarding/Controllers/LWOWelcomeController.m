//
// LWOWelcomeController.m
// LockWatch
//
// Created by janikschmidt on 7/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWOWelcomeController.h"

#import "Core/LWPreferences.h"

@implementation LWOWelcomeController

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	[super buttonTapped:button];
	
	if (button == self.secondaryTrayButton) {
		[self.flowItemDelegate dismissWithSetupCompletionState:YES];
	}
}

- (void)setupWillDismissWithCompletionState:(BOOL)completed {
	if (completed) {
		[[NSClassFromString(@"LWPreferences") sharedInstance] setOnBoardingCompleted:YES];
		[[NSClassFromString(@"LWPreferences") sharedInstance] setUpgradeLastVersion:[NSString stringWithUTF8String:__VERSION]];
		[[NSClassFromString(@"LWPreferences") sharedInstance] synchronize];
	}
}

@end