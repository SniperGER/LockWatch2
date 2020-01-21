//
//  LWClockViewController.h
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core/LWClockViewDelegate.h"
#import "Core/LWFaceLibraryViewControllerDelegate.h"
#import "Core/NTKFaceStyle.h"

@class CLKDevice, LWFaceLibraryViewController, NTKFaceCollection;

@interface LWClockViewController : UIViewController <LWClockViewDelegate, LWFaceLibraryViewControllerDelegate>

@property (nonatomic, readonly) CLKDevice* device;
@property (nonatomic) LWFaceLibraryViewController* libraryViewController;
@property (nonatomic, readonly) NTKFaceCollection* addableFaceCollection;
@property (nonatomic, readonly) NTKFaceCollection* libraryFaceCollection;

- (void)createOrRecreateFaceContent;
- (void)freezeCurrentFace;
- (BOOL)isFaceStyleRestricted:(NTKFaceStyle)style forDevice:(CLKDevice*)device;
- (void)loadAddableFaceCollection;
- (void)loadLibraryFaceCollection;
- (void)maybeSetOrbEnabled:(BOOL)enabled;
- (void)teardownExistingFaceViewControllerIfNeeded;
- (void)unfreezeCurrentFace;
- (void)__addChildViewController:(UIViewController*)viewController;
- (void)__removeChildViewController:(UIViewController*)viewController;

@end