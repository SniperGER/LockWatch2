//
// FSVLOBSetupFlowController.h
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Foundation/Foundation.h>

#import "FSVLOBFlowItemDelegate.h"
#import "FSVLOBBaseSetupControllerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class OBNavigationController;

@interface FSVLOBSetupFlowController : NSObject <FSVLOBFlowItemDelegate> {
	UIWindow* _window;
	OBNavigationController* _navigationController;
	
	NSMutableDictionary<NSString*, UIViewController <FSVLOBBaseSetupControllerInterface>*>* _flowControllers;
	NSString* _currentFlowController;
	
	NSDictionary* flowItems;
}

+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)hideSetupWindowAnimated:(BOOL)animated completion:(void (^)())completion;
- (BOOL)isPresentingSetupFlow;
- (void)showSetupWindowAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END