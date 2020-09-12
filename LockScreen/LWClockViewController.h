//
// LWClockViewController.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>
#import <NanoTimeKitCompanion/NTKFaceCollectionObserver-Protocol.h>

#import "Core/LWClockViewDelegate.h"
#import "Core/LWFaceLibraryViewControllerDelegate.h"
#import "Core/LWORBTapGestureRecognizerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class _UILegibilitySettings, CLKDevice, LWClockFrameViewController, LWFaceLibraryViewController, LWORBAnimator, LWORBTapGestureRecognizer, LWPersistentFaceCollection, LWPreferences, NTKFaceCollection, NTKFaceViewController;

@interface LWClockViewController : UIViewController <LWClockViewDelegate, LWFaceLibraryViewControllerDelegate, LWORBTapGestureRecognizerDelegate, NTKFaceCollectionObserver> {
	LWFaceLibraryViewController* _libraryViewController;
	BOOL _libraryViewIsPresented;
	LWORBTapGestureRecognizer* _orbRecognizer;
	LWORBAnimator* _orbAnimator;
	BOOL _orbZoomActive;
	BOOL _haveLoadedView;
	BOOL _haveFinishedLoadingView;
	NSTimer* _libraryTimeoutTimer;
	CAShapeLayer* _contentViewMask;
	NSInteger _effectiveInterfaceOrientation;
}

@property (class, nonatomic) _UILegibilitySettings* legibilitySettings;

@property (nonatomic, readonly) LWClockFrameViewController* clockFrameController;
@property (nonatomic, readonly) NTKFaceViewController* faceViewController;
@property (nonatomic, readonly) LWPreferences* preferences;
@property (nonatomic) CLKDevice* device;
@property (nonatomic, readonly) NTKFaceCollection* addableFaceCollection;
@property (nonatomic, readonly) NTKFaceCollection* externalFaceCollection;
@property (nonatomic, readonly) NTKFaceCollection* libraryFaceCollection;
@property (nonatomic) CGFloat alignmentPercent;
@property (nonatomic) UIEdgeInsets dateViewInsets;

- (instancetype)init;
- (void)loadView;
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (BOOL)_canShowWhileLocked;
- (void)__addChildViewController:(UIViewController*)viewController;
- (void)__removeChildViewController:(UIViewController*)viewController;
- (void)_beginOrbZoom;
- (void)_createOrRecreateFaceContent;
- (void)_endFaceLibraryControllerPresentation;
- (void)_endOrbZoom:(BOOL)latched;
- (void)_finishLoadingViewIfNecessary;
- (BOOL)_hasRealFaceCollections;
- (void)_maybeSetOrbEnabled:(BOOL)enabled;
- (NTKFaceViewController*)_newFaceControllerForFace:(NTKFace*)face withConfiguration:(void (^)(NTKFaceViewController*))configuration;
- (void)_putLibraryViewControllerIntoClockViewController;
- (void)_setOrbZoomProgress:(CGFloat)progress;
- (void)_teardownExistingFaceViewControllerIfNeeded;
- (void)_updateMask;
- (void)dismissCustomizationViewControllers:(BOOL)animated;
- (void)dismissFaceLibraryAnimated:(BOOL)animated;
- (BOOL)faceLibraryIsPresented;
- (void)freezeCurrentFace;
- (BOOL)isIncrementallyZooming;
- (BOOL)isLandscapePhone;
- (void)layoutForDateViewController:(UIViewController*)dateViewController withEffectiveInterfaceOrientation:(NSInteger)interfaceOrientation;
- (void)loadAddableFaceCollection;
- (void)loadLibraryFaceCollection;
- (void)setAlignmentPercent:(CGFloat)alignmentPercent;
- (void)unfreezeCurrentFace;

@end

NS_ASSUME_NONNULL_END