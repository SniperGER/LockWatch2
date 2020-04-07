#include "LWRootListController.h"
#include "LWWhatsNewController.h"
#include <spawn.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@implementation LWRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	
	prefBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LockWatch2Preferences.bundle"];
	localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];

	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}



- (void)resetLibrary {
	BOOL isiPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
	
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[prefBundle localizedStringForKey:@"RESET_LIBRARY_TITLE" value:nil table:@"Root"]
																			 message:[prefBundle localizedStringForKey:@"RESET_LIBRARY_PROMPT" value:nil table:@"Root"]
																	  preferredStyle:(isiPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet)];
	
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:[prefBundle localizedStringForKey:@"RESET_LIBRARY_CONFIRM" value:nil table:@"Root"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ml.festival.lockwatch2/ResetLibrary" object:nil userInfo:nil];
	}];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CANCEL" value:nil table:nil] style:UIAlertActionStyleCancel handler:nil];
	
	[alertController addAction:confirmAction];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)respring {
	BOOL isiPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
	
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[prefBundle localizedStringForKey:@"RESTART_SPRINGBOARD_TITLE" value:nil table:@"Root"]
																			 message:[prefBundle localizedStringForKey:@"RESTART_SPRINGBOARD_PROMPT" value:nil table:@"Root"]
																	  preferredStyle:(isiPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet)];
	
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:[prefBundle localizedStringForKey:@"RESTART_SPRINGBOARD_CONFIRM" value:nil table:@"Root"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
		pid_t pid;
		int status;
		const char* args[] = {"killall", "-9", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		waitpid(pid, &status, WEXITED);
	}];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CANCEL" value:nil table:nil] style:UIAlertActionStyleCancel handler:nil];
	
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)showWhatsNew {
	LWWhatsNewController* whatsNewController = [LWWhatsNewController new];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:whatsNewController];
	[navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)reportIssue {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/SniperGER/LockWatch2"] options:@{} completionHandler:nil];
}

- (void)makeDonation {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/SniperGER"] options:@{} completionHandler:nil];
}

@end
