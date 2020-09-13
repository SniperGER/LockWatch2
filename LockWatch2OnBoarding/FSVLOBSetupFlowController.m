//
// FSVLOBSetupFlowController.m
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <OnBoardingKit/OnBoardingKit.h>

#import "FSVLOBSetupFlowController.h"

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

@interface UIWindow (Private)
- (void)_setSecure:(BOOL)arg1;
@end



@implementation FSVLOBSetupFlowController

+ (instancetype)sharedInstance {
    static FSVLOBSetupFlowController* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSVLOBSetupFlowController alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
		[_window setRootViewController:[UIViewController new]];
		[_window setWindowLevel:1000];
		[_window _setSecure:YES];
		
		[[NSClassFromString(@"OBImageView") appearanceWhenContainedInInstancesOfClasses:@[ OBBaseWelcomeController.class ]] setTintColor:UIColor.systemOrangeColor];
		[[OBBoldTrayButton appearanceWhenContainedInInstancesOfClasses:@[ OBBaseWelcomeController.class ]] setTintColor:UIColor.systemOrangeColor];
		[[OBLinkTrayButton appearanceWhenContainedInInstancesOfClasses:@[ OBBaseWelcomeController.class ]] setTintColor:UIColor.systemOrangeColor];
		
		_flowControllers = [NSMutableDictionary dictionary];
		flowItems = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/LockWatch2OnBoarding/OnBoarding.plist"];
		
		[flowItems[@"Items"] enumerateObjectsUsingBlock:^(NSDictionary* flowItem, NSUInteger index, BOOL* stop) {
			if (!flowItem[@"Controller"] || !NSClassFromString(flowItem[@"Controller"])) return;
			
			Class controllerClass = NSClassFromString(flowItem[@"Controller"]);
			if (![controllerClass conformsToProtocol:@protocol(FSVLOBBaseSetupControllerInterface)]) return;
			
			BOOL hasDetailText = flowItem[@"DetailText"] != nil;
			BOOL hasIcon = flowItem[@"Icon"] != nil;
			BOOL hasSymbol = flowItem[@"SymbolName"] != nil;
			
			UIViewController <FSVLOBBaseSetupControllerInterface>* controller;
			
			if (hasDetailText || hasIcon || hasSymbol) {
				if (hasSymbol && [controllerClass instancesRespondToSelector:@selector(initWithTitle:detailText:symbolName:)]) {
					controller = [[controllerClass alloc] initWithTitle:LWOLocalizedString(flowItem[@"Title"], nil) detailText:LWOLocalizedString(flowItem[@"DetailText"], nil) symbolName:flowItem[@"SymbolName"]];
				} else if ([controllerClass instancesRespondToSelector:@selector(initWithTitle:detailText:icon:)]) {
					UIImage* iconImage = [UIImage imageNamed:flowItem[@"Icon"] inBundle:LWOLocalizableBundle() compatibleWithTraitCollection:nil];
					if (!iconImage)  {
						iconImage = [UIImage imageWithContentsOfFile:flowItem[@"icon"]];
					}
					
					controller = [[controllerClass alloc] initWithTitle:LWOLocalizedString(flowItem[@"Title"], nil) detailText:LWOLocalizedString(flowItem[@"DetailText"], nil) icon:iconImage];
				}
			} else {
				if ([controllerClass instancesRespondToSelector:@selector(initWithTitle:)]) {
					controller = [[controllerClass alloc] initWithTitle:LWOLocalizedString(flowItem[@"Title"], nil)];
				} else if ([controllerClass instancesRespondToSelector:@selector(initWithTitle:detailText:icon:)]) {
					controller = [[controllerClass alloc] initWithTitle:LWOLocalizedString(flowItem[@"Title"], nil) detailText:nil icon:nil];
				}
			}
			
			if (!controller || !flowItem[@"ItemIdentifier"]) return;
			
			[controller setFlowItemDefinition:flowItem];
			[controller setFlowItemDelegate:self];
			
			[_flowControllers setObject:controller forKey:flowItem[@"ItemIdentifier"]];
			
			if (flowItem[@"BulletedItems"]) {
				[flowItem[@"BulletedItems"] enumerateObjectsUsingBlock:^(NSDictionary* item, NSUInteger index, BOOL* stop) {
					BOOL isBulletedItem = !item[@"Type"] || [item[@"Type"] isEqualToString:@"BulletedItem"];
					BOOL isSection = [item[@"Type"] isEqualToString:@"Section"];
					
					if (isSection && [controllerClass instancesRespondToSelector:@selector(addSectionWithHeader:content:)]) {
						[controller addSectionWithHeader:LWOLocalizedString(item[@"Title"], nil) content:LWOLocalizedString(item[@"Description"], nil)];
					} else if (isBulletedItem) {
						UIImage* itemImage = [UIImage imageNamed:item[@"Image"] inBundle:LWOLocalizableBundle() compatibleWithTraitCollection:nil];
						if (!itemImage)  {
							itemImage = [UIImage imageWithContentsOfFile:item[@"Image"]];
						}
						
						if ([controllerClass instancesRespondToSelector:@selector(addBulletedListItemWithTitle:description:image:)]) {
							[controller addBulletedListItemWithTitle:LWOLocalizedString(item[@"Title"], nil) description:LWOLocalizedString(item[@"Description"], nil) image:itemImage];
						} else if ([controllerClass instancesRespondToSelector:@selector(addBulletedListItemWithDescription:image:)]) {
							[controller addBulletedListItemWithDescription:LWOLocalizedString(item[@"Description"], nil) image:itemImage];
						}
					}
				}];
			}
			
			if (flowItem[@"Buttons"] && [controllerClass instancesRespondToSelector:@selector(buttonTray)]) {
				[flowItem[@"Buttons"] enumerateObjectsUsingBlock:^(NSDictionary* button, NSUInteger index, BOOL* stop) {
					OBTrayButton* trayButton;
					
					if (!button[@"Type"] || [button[@"Type"] isEqualToString:@"Link"]) {
						trayButton = [OBLinkTrayButton linkButton];
					} else {
						trayButton = [OBBoldTrayButton boldButton];
					}
					
					[trayButton setTitle:LWOLocalizedString(button[@"Title"], nil) forState:UIControlStateNormal];
					
					[trayButton addTarget:controller action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
					
					if (!controller.primaryTrayButton) {
						controller.primaryTrayButton = trayButton;
					} else if (!controller.secondaryTrayButton) {
						controller.secondaryTrayButton = trayButton;
					}
					
					[controller.buttonTray addButton:trayButton];
				}];
			}
			
			if (flowItem[@"IsRootController"] && [flowItem[@"IsRootController"] boolValue] && !_navigationController) {
				_navigationController = [[OBNavigationController alloc] initWithRootViewController:controller];
				_currentFlowController = flowItem[@"ItemIdentifier"];
			}
		}];
		
		if (_navigationController) {
			[_navigationController setModalPresentationStyle:UIModalPresentationFullScreen];
			[_navigationController.view removeGestureRecognizer:_navigationController.interactivePopGestureRecognizer];
			[_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
			[_navigationController.navigationBar setShadowImage:[UIImage new]];
			[_navigationController.navigationBar setTranslucent:YES];
			[_navigationController.navigationBar setBackgroundColor:[UIColor systemBackgroundColor]];
			[_navigationController.navigationBar setTintColor:UIColor.systemOrangeColor];
			
			if (@available(iOS 13, *)) {
				[_navigationController setModalInPresentation:YES];
			}
		}
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)hideSetupWindowAnimated:(BOOL)animated completion:(void (^)())completion {
	[_navigationController dismissViewControllerAnimated:animated completion:^{
		[self resetFlowAnimated:NO];
		[_window setHidden:YES];
		
		if (completion) completion();
	}];
}

- (BOOL)isPresentingSetupFlow {
	return !_window.hidden && _navigationController.presentingViewController != nil;
}

- (void)showSetupWindowAnimated:(BOOL)animated {
	if (!_navigationController) return;
	
	[self resetFlowAnimated:NO];
	
	[_window setFrame:UIScreen.mainScreen.bounds];
	[_window makeKeyAndVisible];
	
	[_window.rootViewController presentViewController:_navigationController animated:animated completion:nil];
}

#pragma mark - FSVLOBFlowItemDelegate

- (void)moveToFlowItem:(NSString*)itemIdentifier animated:(BOOL)animated {
	if (_flowControllers[itemIdentifier]) {
		if ([_flowControllers[_currentFlowController] respondsToSelector:@selector(willMoveToFlowItem:animated:)]) {
			[_flowControllers[_currentFlowController] willMoveToFlowItem:itemIdentifier animated:animated];
		}
		
		[_navigationController pushViewController:_flowControllers[itemIdentifier] animated:animated];
		_currentFlowController = itemIdentifier;
		
		if ([_flowControllers[_currentFlowController] respondsToSelector:@selector(didMoveToFlowItem:animated:)]) {
			[_flowControllers[_currentFlowController] didMoveToFlowItem:itemIdentifier animated:animated];
		}
	}
}

- (void)resetFlowAnimated:(BOOL)animated {
	[_navigationController popToRootViewControllerAnimated:animated];
}

- (void)dismissWithSetupCompletionState:(BOOL)completed {
	if ([_flowControllers[_currentFlowController] respondsToSelector:@selector(setupWillDismissWithCompletionState:)]) {
		[_flowControllers[_currentFlowController] setupWillDismissWithCompletionState:completed];
	}
	
	[self hideSetupWindowAnimated:YES completion:^{
		if ([_flowControllers[_currentFlowController] respondsToSelector:@selector(setupDidDismissWithCompletionState:)]) {
			[_flowControllers[_currentFlowController] setupDidDismissWithCompletionState:completed];
		}
	}];
}

@end