//
// OnBoarding.xm
// LockWatch2
//
// Created by janikschmidt on 7/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "OnBoarding.h"

NSBundle* LWOLocalizableBundle() {
	static NSBundle* bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2OnBoarding"];
    });
	
	return bundle;
}

NSBundle* LWOPreferencesBundle() {
	static NSBundle* bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LockWatch2Preferences.bundle"];
    });
	
	return bundle;
}

NSString* LWOLocalizedString(NSString* key, NSString* value) {
	return [LWOLocalizableBundle() localizedStringForKey:key value:value table:@"OnBoarding"];
}



static NSMutableDictionary* bulletinActionCache = [NSMutableDictionary dictionary];

BBBulletinRequest* publishBulletinRequest(NSString* publisherBulletinID, NSDictionary* userInfo, void (^defaultAction)() = NULL, void (^dismissAction)() = NULL) {
	BBBulletinRequest* bulletin = [BBBulletinRequest new];
	if (userInfo[@"header"]) [bulletin setHeader:userInfo[@"header"]];
	if (userInfo[@"title"]) [bulletin setTitle:userInfo[@"title"]];
	if (userInfo[@"message"]) [bulletin setMessage:userInfo[@"message"]];

	NSString* bulletinUUID = [[NSUUID UUID] UUIDString];
	[bulletin setSection:@"com.apple.Preferences"];
	[bulletin setSectionID:@"com.apple.Preferences"];
	[bulletin setBulletinID:bulletinUUID];
	[bulletin setBulletinVersionID:bulletinUUID];
	[bulletin setRecordID:bulletinUUID];
	[bulletin setPublisherBulletinID:publisherBulletinID];
	[bulletin setDate:[NSDate date]];
	[bulletin setClearable:YES];
	[bulletin setDefaultAction:[BBAction action]];
	
	NSMutableDictionary* actions = [NSMutableDictionary dictionary];
	if (defaultAction) [actions setObject:defaultAction forKey:@"default"];
	if (dismissAction) [actions setObject:dismissAction forKey:@"dismiss"];
	
	[bulletinActionCache setObject:actions forKey:bulletinUUID];

	dispatch_async(__BBServerQueue, ^{
		[bulletinServer publishBulletinRequest:bulletin destinations:8];
	});
	
	return bulletin;
}

void showLWOnboardingViewController() {
	FSVLOBSetupFlowController* flowController = [FSVLOBSetupFlowController sharedInstance];
	
	[flowController showSetupWindowAnimated:YES];
}

void showLWWhatsNewController() {
	UIViewController* whatsNewController = [%c(LWWhatsNewController) new];
	
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:whatsNewController];
	[navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
	[navigationController.navigationBar setTintColor:UIColor.systemOrangeColor];
	
	if (@available(iOS 13, *)) {
		[navigationController setModalInPresentation:YES];
	}
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
#pragma GCC diagnostic pop
}

void showLWOnBoardingNotification() {
	FSVLOBSetupFlowController* flowController = [FSVLOBSetupFlowController sharedInstance];
	if ([flowController isPresentingSetupFlow]) return;
	
	publishBulletinRequest(@"ml.festival.lockwatch2.onboarding", @{
		@"header": LWOLocalizedString(@"ONBOARDING_COMMON_HEADER", nil),
		@"title": LWOLocalizedString(@"ONBOARDING_NOTIFICATION_TITLE", nil),
		@"message": LWOLocalizedString(@"ONBOARDING_NOTIFICATION_MESSAGE", nil)
	}, ^{
		showLWOnboardingViewController();
	});
}

void showLWUpgradeNotification() {
	FSVLOBSetupFlowController* flowController = [FSVLOBSetupFlowController sharedInstance];
	if ([flowController isPresentingSetupFlow]) return;
	
	publishBulletinRequest(@"ml.festival.lockwatch2.upgradeFinished", @{
		@"header": LWOLocalizedString(@"ONBOARDING_COMMON_HEADER", nil),
		@"title": LWOLocalizedString(@"ONBOARDING_UPGRADE_NOTIFICATION_TITLE", nil),
		@"message": LWOLocalizedString(@"ONBOARDING_UPGRADE_NOTIFICATION_MESSAGE", nil)
	}, ^{
		showLWWhatsNewController();
	});
}


%hook BBBulletin
- (id)responseForAction:(BBAction*)arg1 {
	id r = %orig;
	if (![self.publisherBulletinID hasPrefix:@"ml.festival.lockwatch2"]) return r;
	
	
	if (arg1.actionType == 0) {
		// User actively dismissed notification or locked device
		
		if (bulletinActionCache[self.bulletinID] && bulletinActionCache[self.bulletinID][@"dismiss"]) {
			[bulletinActionCache[self.bulletinID][@"dismiss"] performSelector:@selector(invoke)];
		}
	} else if (arg1.actionType == 1) {
		// User engaged with notification
		[[%c(SBBannerController) sharedInstance] dismissBannerWithAnimation:YES reason:0 forceEvenIfBusy:YES];
		
		if (bulletinActionCache[self.bulletinID] && bulletinActionCache[self.bulletinID][@"default"]) {
			[bulletinActionCache[self.bulletinID][@"default"] performSelector:@selector(invoke)];
		}
	}

	return r;
}

- (BBSectionIcon*)sectionIcon {
	id r = %orig;
	if (![self.publisherBulletinID hasPrefix:@"ml.festival.lockwatch2"]) return r;
	
	BBSectionIcon *icon = [[BBSectionIcon alloc] init];
    [icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageName: @"icon" inBundle:LWOPreferencesBundle()]];
    return icon;
}
%end	/// %hook BBBulletin

%hook BBServer
- (id)initWithQueue:(id)arg1 {
	bulletinServer = %orig;
	return bulletinServer;
}

- (void)dealloc {
	if (bulletinServer == self) bulletinServer = nil;
	%orig;
}
%end	/// %hook BBServer

%hook SpringBoard
%new
- (void)showLWOnBoardingNotificationIfNecessary {
	if (!preferences.onBoardingCompleted && !didShowOnBoardingNotification) {
		didShowOnBoardingNotification = YES;
		
		showLWOnBoardingNotification();
	}
}

%new
- (void)showLWUpgradeNotificationIfNecessary {
	if (preferences.onBoardingCompleted && (!preferences.upgradeLastVersion || ![preferences.upgradeLastVersion isEqualToString:[NSString stringWithUTF8String:__VERSION]]) && !didShowUpgradeNotification) {
		didShowUpgradeNotification = YES;
		
		[preferences setUpgradeLastVersion:[NSString stringWithUTF8String:__VERSION]];
		[preferences synchronize];
		
		showLWUpgradeNotification();
	}
}
%end	/// %hook SpringBoard

%hook CSCoverSheetViewController
- (void)viewDidDisappear:(BOOL)arg1 {
	%orig;
	
	// DEBUG!
	[(SpringBoard*)[UIApplication sharedApplication] showLWOnBoardingNotificationIfNecessary];
	[(SpringBoard*)[UIApplication sharedApplication] showLWUpgradeNotificationIfNecessary];
	
}
%end	/// %hook CSCoverSheetViewController



%ctor {
	@autoreleasepool {
		preferences = [%c(LWPreferences) sharedInstance];
		
		if (preferences.enabled) {
			dlopen("/Library/PreferenceBundles/LockWatch2Preferences.bundle/LockWatch2Preferences", RTLD_NOW);
			
			%init();
		}
	}
}