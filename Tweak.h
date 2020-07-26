//
// Tweak.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.lockwatch2.list"

#if TARGET_OS_SIMULATOR
#define WATCH_DATA_PATH @"/Users/janikschmidt/Desktop/EmulatedDevices.plist"
#else
#define WATCH_DATA_PATH @"/Library/Application Support/LockWatch2/EmulatedDevices.plist"
#endif

#include <substrate.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>
#import <NTKCustomization/NTKCCLibraryListViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

#import "UIWindow+Orientation.h"

#import "Core/LWPreferences.h"
#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWEmulatedNRDevice.h"
#import "Core/LWPersistentFaceCollection.h"
#import "LockScreen/LWClockView.h"
#import "LockScreen/LWClockViewController.h"

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();



/**
 * Headers
 */

@class CSCoverSheetViewController, CSMainPageContentViewController, NTKCCFacesViewController, SBFLockScreenDateViewController, SBFLockScreenDateView;

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (CSCoverSheetViewController*)coverSheetViewController;
@end

@interface CSCoverSheetViewController : UIViewController
- (CSMainPageContentViewController*)mainPageContentViewController;
- (SBFLockScreenDateViewController*)dateViewController;
- (UIWindow*)_window;
@end

@interface CSFixedFooterView : UIView
@end

@interface CSMainPageContentViewController : UIViewController
@end

@interface CSCombinedListViewController : UIViewController
- (void)_updateListViewContentInset;
@end

@interface SBFLockScreenDateViewController : UIViewController
- (id)ptnFaceViewController;
@end

@interface SBFLockScreenDateView : UIView
- (CGRect)restingFrame;
@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic, readonly) BOOL screenIsOn;
@end

@interface COSSettingsListController : PSListController
- (UITableView*)table;
- (NTKCCFacesViewController*)facesController;
@end

@interface NTKCCFacesViewController : UIViewController
- (NTKFaceCollection*)library;
@end

@interface UIWindow (Private)
- (UIInterfaceOrientation)interfaceOrientation;
@end

/**
 * Instances
 */

static LWPreferences* preferences;
static LWClockViewController* clockViewController;