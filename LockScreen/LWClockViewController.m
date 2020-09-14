//
// LWClockViewController.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <AudioToolbox/AudioServices.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "LWAddPageViewController.h"
#import "LWClockFrameViewController.h"
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
		// _device = [CLKDevice currentDevice];

		CLKDevice* device = [CLKDevice currentDevice];
		if (!device || !device.nrDevice) return nil;
		
		[self loadAddableFaceCollection];
		[self loadExternalFaceCollection];
		[self loadLibraryFaceCollection];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/ResetLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			_libraryFaceCollection = [LWPersistentFaceCollection defaultLibraryFaceCollectionForDevice:[CLKDevice currentDevice]];
			[_libraryFaceCollection addObserver:self];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/AddToLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			NTKFace* face = [NTKFace faceWithJSONObjectRepresentation:notification.userInfo[@"faceJSON"] forDevice:[CLKDevice currentDevice]];
			[_libraryFaceCollection appendFace:face suppressingCallbackToObserver:self];
			[_libraryFaceCollection setSelectedFace:face suppressingCallbackToObserver:self];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ml.festival.lockwatch2/SyncLibrary" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			_libraryFaceCollection = [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:@"LibraryFaces" forDevice:[CLKDevice currentDevice] JSONObjectRepresentation:notification.userInfo[@"faceJSON"]];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
			
			[self _createOrRecreateFaceContent];
		}];
	}
	
	return self;
}

- (void)loadView {
	LWClockView* view = [[LWClockView alloc] initWithFrame:(CGRect){
		CGPointZero,
		{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight([[CLKDevice currentDevice] actualScreenBounds]) }
	}];
	
	[view setDelegate:self];
	
	self.view = view;
	
	_haveLoadedView = YES;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	CLKDevice* device = [CLKDevice currentDevice];
	CGFloat _centerX = 0;
	
	if ([self isLandscapePhone]) {
		_centerX = (CGRectGetMinX(CGRectInset(self.view.bounds, _dateViewInsets.left, 0)) + (CGRectGetWidth(device.actualScreenBounds) / 2)) + ((CGRectGetWidth(CGRectInset(self.view.bounds, _dateViewInsets.left, 0)) - CGRectGetWidth(device.actualScreenBounds)) * CLAMP(_alignmentPercent + 1, 0, 2));
		
		CGFloat scale = [[LWPreferences sharedInstance] scaleLandscapePhone];
		[_libraryViewController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
		[_clockFrameController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
	} else if (UIInterfaceOrientationIsPortrait(_effectiveInterfaceOrientation)) {
		_centerX = CGRectGetMidX(UIScreen.mainScreen.bounds) + [[LWPreferences sharedInstance] horizontalOffsetPortrait];
		
		CGFloat scale = [[LWPreferences sharedInstance] scalePortrait];
		[_libraryViewController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
		[_clockFrameController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
	} else if (UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation)) {
		_centerX = CGRectGetMidX(UIScreen.mainScreen.bounds) + [[LWPreferences sharedInstance] horizontalOffsetLandscape];
		
		CGFloat scale = [[LWPreferences sharedInstance] scaleLandscape];
		[_libraryViewController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
		[_clockFrameController.view setTransform:CGAffineTransformMakeScale(scale, scale)];
	}
	
	[_libraryViewController.view setCenter:(CGPoint) {
		_centerX,
		_libraryViewController.view.center.y
	}];
	
	[_clockFrameController.view setCenter:_libraryViewController.view.center];
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
	
	if (_clockFrameController ) {
		[self __removeChildViewController:_clockFrameController];
	}
	
	_clockFrameController = [LWClockFrameViewController new];
	[self __addChildViewController:_clockFrameController];
	
	if (_libraryViewController) {
		[_libraryViewController setDelegate:nil];
		[self __removeChildViewController:_libraryViewController];
	}
	
	_libraryViewIsPresented = NO;
	
	_libraryViewController = [[LWFaceLibraryViewController alloc] initWithLibraryCollection:_libraryFaceCollection addableCollection:_addableFaceCollection externalFaceCollection:_externalFaceCollection];
	[_libraryViewController setDelegate:self];
	
	[self _putLibraryViewControllerIntoClockViewController];
	[_libraryViewController.view layoutIfNeeded];
	
	if ([[LWPreferences sharedInstance] showCase] && _clockFrameController.caseImage != nil) {
		[_libraryViewController.view setClipsToBounds:YES];
	}
	
	CLKDevice* device = [CLKDevice currentDevice];
	
	[NSLayoutConstraint activateConstraints:@[
		[_libraryViewController.view.widthAnchor constraintEqualToConstant:CGRectGetWidth(device.actualScreenBounds)],
		[_libraryViewController.view.heightAnchor constraintEqualToConstant:CGRectGetHeight(device.actualScreenBounds)]
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
	[_contentViewMask setFrame:(CGRect){{ 0, -CGRectGetMinY(self.view.frame) }, { CGRectGetWidth(maskBounds), CGRectGetHeight(maskBounds) }}];
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

- (BOOL)isLandscapePhone {
	return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation);
}

- (void)layoutForDateViewController:(UIViewController*)dateViewController withEffectiveInterfaceOrientation:(NSInteger)interfaceOrientation {
	_effectiveInterfaceOrientation = interfaceOrientation;
	
	[self setDateViewInsets:(UIEdgeInsets) {
		0,
		(CGRectGetWidth(UIScreen.mainScreen.bounds) - CGRectGetWidth(dateViewController.view.bounds)) / 2,
		0,
		(CGRectGetWidth(UIScreen.mainScreen.bounds) - CGRectGetWidth(dateViewController.view.bounds)) / 2,
	}];
	
	if (![self isLandscapePhone]) {
		[self.view setFrame:(CGRect){
			CGPointZero,
			{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(self.view.bounds) }
		}];
	} else {
		[self.view setFrame:(CGRect){
			{ (CGRectGetWidth(UIScreen.mainScreen.bounds) * (CLAMP(_alignmentPercent + 1, 0, 2) * -1)), 0 },
			{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(self.view.bounds) }
		}];
	}
		
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	CGFloat dateViewControllerVerticalPosition = (dateViewController.view.layer.position.y - (CGRectGetHeight(dateViewController.view.bounds) / 2));
	
	CGFloat _centerY = 0;
	
	if ([self isLandscapePhone]) {
		_centerY = (CGRectGetHeight(self.view.bounds) / 2) + 48 + [[LWPreferences sharedInstance] verticalOffsetLandscapePhone];
	} else if (UIInterfaceOrientationIsPortrait(_effectiveInterfaceOrientation)) {
		_centerY = (dateViewControllerVerticalPosition + [[LWPreferences sharedInstance] verticalOffsetPortrait]) + (CGRectGetHeight(self.view.bounds) / 2);
	} else if (UIInterfaceOrientationIsLandscape(_effectiveInterfaceOrientation)) {
		_centerY = (dateViewControllerVerticalPosition + [[LWPreferences sharedInstance] verticalOffsetLandscape]) + (CGRectGetHeight(self.view.bounds) / 2);
	}
	
	[self.view setCenter:(CGPoint) {
		self.view.center.x,
		_centerY
	}];
	
	[self _updateMask];
}

- (void)loadAddableFaceCollection {
	_addableFaceCollection = [LWPersistentFaceCollection defaultAddableFaceCollectionForDevice:[CLKDevice currentDevice]];
}

- (void)loadExternalFaceCollection {
	_externalFaceCollection = [LWPersistentFaceCollection externalFaceCollectionForDevice:[CLKDevice currentDevice]];
}

- (void)loadLibraryFaceCollection {
	_libraryFaceCollection = [LWPersistentFaceCollection faceCollectionWithContentsOfFile:LIBRARY_PATH 
																	 collectionIdentifier:@"LibraryFaces"
																				forDevice:[CLKDevice currentDevice]];
	if (!_libraryFaceCollection) {
		_libraryFaceCollection = [LWPersistentFaceCollection defaultLibraryFaceCollectionForDevice:[CLKDevice currentDevice]];
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
	if ([[(SpringBoard*)[UIApplication sharedApplication] pluginUserAgent] deviceIsPasscodeLocked]) return NO;
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