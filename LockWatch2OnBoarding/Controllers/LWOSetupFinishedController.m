//
// LWOSetupFinishedController.m
// LockWatch
//
// Created by janikschmidt on 7/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#include <spawn.h>

#import "LWOSetupFinishedController.h"

#import "Core/LWPreferences.h"

extern NSBundle* LWOPreferencesBundle();
extern NSString* LWOLocalizedString(NSString* key, NSString* value);

@implementation LWOSetupFinishedController

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)setupWillDismissWithCompletionState:(BOOL)completed {
	[[NSClassFromString(@"LWPreferences") sharedInstance] setOnBoardingCompleted:YES];
	[[NSClassFromString(@"LWPreferences") sharedInstance] setUpgradeLastVersion:[NSString stringWithUTF8String:__VERSION]];
	[[NSClassFromString(@"LWPreferences") sharedInstance] synchronize];
}

- (void)setupDidDismissWithCompletionState:(BOOL)completed {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:LWOLocalizedString(@"ONBOARDING_RESTART_SPRINGBOARD_TITLE", nil)
																			 message:LWOLocalizedString(@"ONBOARDING_RESTART_SPRINGBOARD_MESSAGE", nil)
																	  preferredStyle:UIAlertControllerStyleAlert];
															
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:[LWOPreferencesBundle() localizedStringForKey:@"RESTART_SPRINGBOARD_CONFIRM" value:nil table:@"Root"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
		pid_t pid;
		int status;
		const char* args[] = {"killall", "-9", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		waitpid(pid, &status, WEXITED);
	}];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[LWOPreferencesBundle() localizedStringForKey:@"RESTART_SPRINGBOARD_CANCEL" value:nil table:@"Root"] style:UIAlertActionStyleCancel handler:nil];
	
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	[UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
#pragma GCC diagnostic pop
}

@end