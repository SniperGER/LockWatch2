//
// LWClockViewController.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define LIBRARY_PATH @"/var/mobile/Library/Preferences/ml.festival.lockwatch2.CurrentFaces.plist"
#define CLAMP(value, min, max) (value - min) / (max - min)

#import <AudioToolbox/AudioServices.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "LWAddPageViewController.h"
#import "LWClockView.h"
#import "LWClockViewController.h"
#import "LWFaceLibraryOverlayView.h"
#import "LWFaceLibraryViewController.h"
#import "LWPageScrollView.h"
#import "LWSwitcherViewController.h"
#import "UIWindow+Orientation.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWEmulatedNRDevice.h"
#import "Core/LWORBAnimator.h"
#import "Core/LWORBTapGestureRecognizer.h"
#import "Core/LWPersistentFaceCollection.h"
#import "Core/LWPreferences.h"

@interface UIDevice (Private)
- (BOOL)_supportsForceTouch;
@end

@interface NTKFaceViewController (Background)
@property (nonatomic, strong) UIView* backgroundView;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface SBUserAgent : NSObject
- (BOOL)deviceIsPasscodeLocked;
@end

@interface SpringBoard : UIApplication
- (SBUserAgent*)pluginUserAgent;
@end



BOOL UIColorIsLightColor(UIColor* color) {
	CGFloat red, green, blue, alpha;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	
	CGFloat brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
	
	return brightness >= 0.5;
}

@implementation LWClockViewController

static _UILegibilitySettings* _legibilitySettings;

+ (_UILegibilitySettings*)legibilitySettings {
	return _legibilitySettings;
}

+ (void)setLegibilitySettings:(_UILegibilitySettings*)legibilitySettings {
	_legibilitySettings = legibilitySettings;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil userInfo:nil];
}

- (instancetype)init {
	if (self = [super init]) {
		_preferences = [LWPreferences sharedInstance];
		_device = [CLKDevice currentDevice];

		if (!_device || !_device.nrDevice) return nil;
		
		[self loadAddableFaceCollection];
		[self loadLibraryFaceCollection];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/ResetLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			_libraryFaceCollection = [LWPersistentFaceCollection defaultLibraryFaceCollectionForDevice:[CLKDevice currentDevice]];
			[_libraryFaceCollection addObserver:self];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/AddToLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			NTKFace* face = [NTKFace faceWithJSONObjectRepresentation:notification.userInfo[@"faceJSON"] forDevice:_device];
			[_libraryFaceCollection appendFace:face suppressingCallbackToObserver:self];
			[_libraryFaceCollection setSelectedFace:face suppressingCallbackToObserver:self];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/SyncLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			_libraryFaceCollection = [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:@"LibraryFaces" forDevice:_device JSONObjectRepresentation:notification.userInfo[@"faceJSON"]];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
	}
	
	return self;
}

- (void)loadView {
	LWClockView* view = [[LWClockView alloc] initWithFrame:(CGRect){
		CGPointZero,
		{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(_device.actualScreenBounds) }
	}];
	
	[view setDelegate:self];
	
	self.view = view;
	
	_haveLoadedView = YES;
}

- (void)didMoveToParentViewController:(nullable UIViewController*)viewController {
	[super didMoveToParentViewController:viewController];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	BOOL isiPhoneLandscape = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation);
	CGFloat _centerX = 0;
	
	if (!isiPhoneLandscape) {
		_centerX = CGRectGetMidX(UIScreen.mainScreen.bounds);
	} else {
		_centerX = (CGRectGetMinX(CGRectInset(self.view.bounds, _dateViewInsets.left, 0)) + (CGRectGetWidth(_device.actualScreenBounds) / 2)) - ((CGRectGetWidth(_device.actualScreenBounds) + _dateViewInsets.left * 2) * CLAMP(_alignmentPercent + 1, 0, 2));
	}
	
	[_libraryViewController.view setCenter:(CGPoint){
		_centerX,
		_libraryViewController.view.center.y
	}];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self _updateMask];
    } completion:nil];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

#pragma mark - Instance Methods

- (void)__addChildViewController:(UIViewController*)viewController {
	if (viewController) {
		[self addChildViewController:viewController];
		[self.view addSubview:viewController.view];
		[viewController didMoveToParentViewController:self];
	}
}

- (void)__removeChildViewController:(UIViewController*)viewController {
	if (viewController.parentViewController == self) {
		[viewController willMoveToParentViewController:nil];
		[viewController.view removeFromSuperview];
		[viewController removeFromParentViewController];
	}
}

- (void)_beginOrbZoom {
	[_faceViewController prepareForOrb];
	_libraryViewIsPresented = YES;
	
	[_libraryViewController beginInteractiveLibraryPresentation];
	
	_orbZoomActive = YES;
}

- (void)_createOrRecreateFaceContent {
	[self _finishLoadingViewIfNecessary];
	[self _teardownExistingFaceViewControllerIfNeeded];
	
	if (_libraryViewController) {
		[_libraryViewController setDelegate:nil];
		[self __removeChildViewController:_libraryViewController];
	}
	
	_libraryViewIsPresented = NO;
	
	_libraryViewController = [[LWFaceLibraryViewController alloc] initWithLibraryCollection:_libraryFaceCollection addableCollection:_addableFaceCollection];
	[_libraryViewController setDelegate:self];
	
	[self _putLibraryViewControllerIntoClockViewController];
	[_libraryViewController.view layoutIfNeeded];
	
	[NSLayoutConstraint activateConstraints:@[
		// [_libraryViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		// [_libraryViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[_libraryViewController.view.widthAnchor constraintEqualToConstant:CGRectGetWidth(_device.actualScreenBounds)],
		[_libraryViewController.view.heightAnchor constraintEqualToConstant:CGRectGetHeight(_device.actualScreenBounds)]
	]];
}

- (void)_endFaceLibraryControllerPresentation {
	_libraryViewIsPresented = NO;
	[_orbRecognizer setEnabled:YES];
}

- (void)_endOrbZoom:(BOOL)latched {
	[_libraryViewController endInteractiveLibraryPresentation];
	
	if (latched) {
		[self _maybeSetOrbEnabled:NO];
	} else {
		[self _endFaceLibraryControllerPresentation];
	}
	
	[_faceViewController cleanupAfterOrb:latched];
	_orbZoomActive = NO;
}

- (void)_finishLoadingViewIfNecessary {
	if (!_haveFinishedLoadingView) {
		_orbRecognizer = [[LWORBTapGestureRecognizer alloc] initWithTarget:nil action:nil];
		[_orbRecognizer setOrbDelegate:self];
		[self.view addGestureRecognizer:_orbRecognizer];
	
		_orbAnimator = [[LWORBAnimator alloc] initWithORBGestureRecognizer:_orbRecognizer];
		
		__weak LWClockViewController* _weak_self = self;
		[_orbAnimator setBeginHandler:^{
			[_weak_self _beginOrbZoom];
		}];
		[_orbAnimator setProgressHandler:^(CGFloat progress) {
			[_weak_self _setOrbZoomProgress:progress];
		}];
		[_orbAnimator setEndHandler:^(BOOL latched) {
			[_weak_self _endOrbZoom:latched];
		}];
		
		_haveFinishedLoadingView = YES;
	}
}

- (BOOL)_hasRealFaceCollections {
	if (_libraryFaceCollection.hasLoaded) {
		return _addableFaceCollection.hasLoaded;
	}
	
	return NO;
}

- (void)_maybeSetOrbEnabled:(BOOL)enabled {
	if (!enabled) {
		[_orbRecognizer setEnabled:NO];
	}
	
	if (_faceViewController.dataMode > 1) return;

	[_orbRecognizer setEnabled:enabled];
}

- (NTKFaceViewController*)_newFaceControllerForFace:(NTKFace*)face withConfiguration:(void (^)(NTKFaceViewController*))configuration {
	NTKFaceViewController* faceViewController = [[NTKFaceViewController alloc] initWithFace:face configuration:configuration];
	
	[faceViewController.backgroundView setHidden:NO];
	[faceViewController configureWithDuration:0.0 block:configuration];
	
	return faceViewController;
}

- (void)_putLibraryViewControllerIntoClockViewController {
	if (_libraryViewController) {
		[self __addChildViewController:_libraryViewController];
		[_libraryViewController activateWithSelectedFaceViewController:_faceViewController];
	}
}

- (void)_teardownExistingFaceViewControllerIfNeeded {
	if (_faceViewController) {
		[self __removeChildViewController:_faceViewController];
		_faceViewController = nil;
	}
}

- (void)_setOrbZoomProgress:(CGFloat)progress {
	[_libraryViewController setInteractiveProgress:progress];
}

- (void)_updateMask {
	CGRect maskBounds = UIScreen.mainScreen.bounds;
	
	_contentViewMask = [CAShapeLayer layer];
	[_contentViewMask setFrame:(CGRect){{ -CGRectGetWidth(maskBounds), -CGRectGetMinY(self.view.frame) }, { CGRectGetWidth(maskBounds) * 2, CGRectGetHeight(maskBounds) }}];
	[_contentViewMask setPath:[UIBezierPath bezierPathWithRect:_contentViewMask.bounds].CGPath];
	[self.view.layer setMask:_contentViewMask];
}


- (void)dismissCustomizationViewControllers:(BOOL)animated {
	[_libraryViewController _stopFaceEditing:animated];
	[_libraryViewController.addFaceViewController dismissAnimated:animated];
}

- (void)dismissFaceLibraryAnimated:(BOOL)animated {
	[_libraryViewController _dismissSwitcherAnimated:animated withIndex:_libraryFaceCollection.selectedFaceIndex];
}

- (BOOL)faceLibraryIsPresented {
	return _libraryViewController.presented;
}

- (void)freezeCurrentFace {
	if (_libraryViewController.selectedFaceViewController.dataMode == 3) return;
	[_libraryViewController.selectedFaceViewController freeze];
}

- (BOOL)isIncrementallyZooming {
	return [_libraryViewController isIncrementallyZooming];
}

- (void)layoutForDateViewController:(UIViewController*)dateViewController withEffectiveInterfaceOrientation:(NSInteger)interfaceOrientation {
	_effectiveInterfaceOrientation = interfaceOrientation;
	
	[self setDateViewInsets:(UIEdgeInsets) {
		0,
		(CGRectGetWidth(UIScreen.mainScreen.bounds) - CGRectGetWidth(dateViewController.view.bounds)) / 2,
		0,
		(CGRectGetWidth(UIScreen.mainScreen.bounds) - CGRectGetWidth(dateViewController.view.bounds)) / 2,
	}];
	
	CGFloat dateViewControllerVerticalPosition = (dateViewController.view.layer.position.y - (CGRectGetHeight(dateViewController.view.bounds) / 2));
	
	[self.view setFrame:(CGRect){
		{ 0, dateViewControllerVerticalPosition },
		{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(self.view.bounds) }
	}];
		
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	BOOL isiPhoneLandscape = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(interfaceOrientation);
			
	[self.view setCenter:(CGPoint) {
		self.view.center.x,
		(isiPhoneLandscape) ? (CGRectGetHeight(self.view.bounds) / 2) + 48 : dateViewControllerVerticalPosition + (CGRectGetHeight(self.view.bounds) / 2)
	}];
	
	[self _updateMask];
}

- (void)loadAddableFaceCollection {
	_addableFaceCollection = [LWPersistentFaceCollection defaultAddableFaceCollectionForDevice:_device];
}

- (void)loadLibraryFaceCollection {
	_libraryFaceCollection = [LWPersistentFaceCollection faceCollectionWithContentsOfFile:LIBRARY_PATH 
																	 collectionIdentifier:@"LibraryFaces"
																				forDevice:_device];
	if (!_libraryFaceCollection) {
		_libraryFaceCollection = [LWPersistentFaceCollection defaultLibraryFaceCollectionForDevice:_device];
	}
	
	[_libraryFaceCollection addObserver:self];
}

- (void)setAlignmentPercent:(CGFloat)alignmentPercent {
	_alignmentPercent = alignmentPercent;
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
}

- (void)unfreezeCurrentFace {
	[_libraryViewController.selectedFaceViewController unfreeze];
}

#pragma mark - LWClockViewDelegate

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	if (!CGRectContainsPoint(self.view.bounds, point)) return nil;
	
	CGPoint convertedPoint = [self.view convertPoint:point toView:_libraryViewController.view];
	UIView* view = [_libraryViewController.libraryOverlayView hitTest:convertedPoint withEvent:event];
	CGRect convertedRect = [_libraryViewController.view convertRect:_libraryViewController.switcherController.scrollView.frame toView:self.view];
	
	if (!view && !CGRectContainsPoint(convertedRect, point)) view = _libraryViewController.switcherController.scrollView;
	if (!view) view = [_libraryViewController.view hitTest:convertedPoint withEvent:event];
	
	if ((!_libraryViewIsPresented && CGRectContainsPoint(convertedRect, point)) || _libraryViewIsPresented) {
		return view;
	}
	
	return nil;
}

#pragma mark - LWORBTapGestureRecoginzerDelegate

- (BOOL)isORBTapGestureAllowed {
#ifndef DEMO_MODE
	if ([[(SpringBoard*)[UIApplication sharedApplication] pluginUserAgent] deviceIsPasscodeLocked]) return NO;
#endif
	
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation)) return NO;
	
	return YES;
}

- (void)ORBTapGestureRecognizerDidLatch:(LWORBTapGestureRecognizer*)orbRecognizer {
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation)) return;
	
	AudioServicesPlaySystemSound(1520);
	[_libraryViewController commitToLibraryPresentation];
}

#pragma mark - LWFaceLibraryViewControllerDelegate

- (NTKFaceViewController*)faceLibraryViewController:(LWFaceLibraryViewController*)libraryViewController newViewControllerForFace:(NTKFace*)face configuration:(void (^)(NTKFaceViewController*))configuration {
	return [self _newFaceControllerForFace:face withConfiguration:configuration];
}

- (void)faceLibraryViewControllerDidCompleteSelection:(LWFaceLibraryViewController*)libraryViewController {
	if (_libraryViewController.selectedFaceViewController != _faceViewController) {
		[self _teardownExistingFaceViewControllerIfNeeded];
		
		_faceViewController = _libraryViewController.selectedFaceViewController;
	}
	
	[self _endFaceLibraryControllerPresentation];
	
	[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
}

- (void)faceLibraryViewControllerWillCompleteSelection:(LWFaceLibraryViewController*)libraryViewController {}

#pragma mark - NTKFaceCollectionObserver

- (void)faceCollectionDidLoad:(NTKFaceCollection *)collection {
	if ([self _hasRealFaceCollections] && !_haveLoadedView) {
		[self _createOrRecreateFaceContent];
	}
}

@end