//
// OnBoarding.h
// LockWatch2
//
// Created by janikschmidt on 7/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <BulletinBoard/BulletinBoard.h>

#import "FSVLOBSetupFlowController.h"

#import "Core/LWPreferences.h"


/**
 * Headers
 */

@interface SpringBoard ()
// %new
- (void)showLWOnBoardingNotificationIfNecessary;
// %new
- (void)showLWUpgradeNotificationIfNecessary;
@end

@interface SBBannerController : NSObject
+ (instancetype)sharedInstance;
- (void)dismissBannerWithAnimation:(BOOL)arg1 reason:(NSInteger)arg2 forceEvenIfBusy:(BOOL)arg3;
@end

/**
 * Instances
 */

static BBServer* bulletinServer;
extern dispatch_queue_t __BBServerQueue;

static LWPreferences* preferences;

static BOOL didShowOnBoardingNotification;
static BOOL didShowUpgradeNotification;