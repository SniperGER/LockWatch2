#include "LWRootListController.h"
#include "LWWhatsNewController.h"
#include <spawn.h>

@implementation LWRootListController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	prefBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LockWatch2Preferences.bundle"];
	localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];
	
	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	
	_emulatedDeviceSelectionSpecifier = [self specifierForID:@"EMULATED_DEVICE"];
	_showWatchBandSpecifier = [self specifierForID:@"SHOW_BAND"];
	_configureCaseSpecifier = [self specifierForID:@"CONFIGURE_CASE_AND_BAND"];
	
	[self removeContiguousSpecifiers:@[ _emulatedDeviceSelectionSpecifier, _showWatchBandSpecifier, _configureCaseSpecifier ] animated:NO];
	
	[self _updateEmulatedWatchAvailability];
	[self _updateCaseConfigurationAvailability];
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
	
	if ([[specifier propertyForKey:@"key"] isEqualToString:@"isEmulatingDevice"]) {
		[self _updateEmulatedWatchAvailability];
	} else if ([[specifier propertyForKey:@"key"] isEqualToString:@"showCase"]) {
		[self _updateCaseConfigurationAvailability];
	}
}

#pragma mark - Instance Methods

- (void)_updateCaseConfigurationAvailability {
	PSSpecifier* showWatchCaseSpecifier = [self specifierForID:@"SHOW_CASE"];
	BOOL showCase = [[self readPreferenceValue:showWatchCaseSpecifier] boolValue];

	if (showCase && ![self containsSpecifier:_showWatchBandSpecifier] && ![self containsSpecifier:_configureCaseSpecifier]) {
		[self insertContiguousSpecifiers:@[ _showWatchBandSpecifier, _configureCaseSpecifier ] afterSpecifier:showWatchCaseSpecifier animated:YES];
	} else if (!showCase) {
		[self removeContiguousSpecifiers:@[ _showWatchBandSpecifier, _configureCaseSpecifier ] animated:YES];
	}
}

- (void)_updateEmulatedWatchAvailability {
	PSSpecifier* useEmulatedDeviceSpecifier = [self specifierForID:@"USE_EMULATED_DEVICE"];
	BOOL isEmulatingDevice = [[self readPreferenceValue:useEmulatedDeviceSpecifier] boolValue];

	if (isEmulatingDevice && ![self containsSpecifier:_emulatedDeviceSelectionSpecifier]) {
		[self insertContiguousSpecifiers:@[ _emulatedDeviceSelectionSpecifier ] afterSpecifier:useEmulatedDeviceSpecifier animated:YES];
	} else if (!isEmulatingDevice) {
		[self removeContiguousSpecifiers:@[ _emulatedDeviceSelectionSpecifier ] animated:YES];
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
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[prefBundle localizedStringForKey:@"RESTART_SPRINGBOARD_CANCEL" value:nil table:@"Root"] style:UIAlertActionStyleCancel handler:nil];
	
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
