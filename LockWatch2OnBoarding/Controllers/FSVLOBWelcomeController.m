//
// FSVLOBWelcomeController.m
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBWelcomeController.h"

@implementation FSVLOBWelcomeController

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	if (button == self.primaryTrayButton) {
		[self.flowItemDelegate moveToFlowItem:[self nextFlowItem] animated:YES];
	}
}

- (NSString*)nextFlowItem {
	return _flowItemDefinition[@"NextFlowItem"];
}

@end