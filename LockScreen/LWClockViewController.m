//
//  LWClockViewController.m
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#define WATCH_DATA_PATH @"/Library/Application Support/LockWatch/WatchData.plist"
#define DEBUG_DEVICE @"Watch5,4"

#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NTKFace.h>
#import <NanoTimeKitCompanion/NTKCompanionFaceViewController.h>

#import "LWClockView.h"
#import "LWClockViewController.h"
#import "LWFaceLibraryViewController.h"
#import "LWPageScrollView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedDevice.h"
#import "Core/LWEmulatedNRDevice.h"
#import "Core/LWPersistentFaceCollection.h"
#import "Core/NTKFaceStyle.h"

@interface LWClockViewController () {
	BOOL _libraryViewIsPresented;
	BOOL _orbZoomActive;
	NTKFaceViewController* _faceViewController;
}

@end

@implementation LWClockViewController 

- (id)init {
	if (self = [super init]) {
		/// TODO: Preferences
		if ([CLKDevice currentDevice] && false) {
			_device = [CLKDevice currentDevice];
		} else {
			NSDictionary* watchData = [[NSDictionary alloc] initWithContentsOfFile:WATCH_DATA_PATH][DEBUG_DEVICE];
		
			NSUUID* uuid = [NSUUID new];
			LWEmulatedNRDevice* nrDevice = [[LWEmulatedNRDevice alloc] initWithJSONRepresentation:watchData[@"registry"] pairingID:uuid];
			
			_device = [[LWEmulatedDevice alloc] initWithJSONRepresentation:watchData[@"device"] nrDevice:nrDevice];
			[CLKDevice setCurrentDevice:_device];
		}
		
		[self loadAddableFaceCollection];
		[self loadLibraryFaceCollection];
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
	
	[self createOrRecreateFaceContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self createOrRecreateFaceContent];
}

- (void)didMoveToParentViewController:(UIViewController*)viewController {
	[super didMoveToParentViewController:viewController];
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.widthAnchor constraintEqualToAnchor:self.view.superview.widthAnchor],
		[self.view.heightAnchor constraintEqualToConstant:CGRectGetHeight(_device.actualScreenBounds)]
	]];
}

#pragma mark - Instance Methods

- (void)createOrRecreateFaceContent {
	if (_libraryViewController) {
		[_libraryViewController setDelegate:nil];
		[self __removeChildViewController:_libraryViewController];
	}
	
	_libraryViewIsPresented = NO;
	
	_libraryViewController = [[LWFaceLibraryViewController alloc] initWithLibraryCollection:_libraryFaceCollection addableCollection:_addableFaceCollection];
	[_libraryViewController setDelegate:self];
	[self __addChildViewController:_libraryViewController];
	[_libraryViewController activateWithSelectedFaceViewController:_faceViewController];
	
	[NSLayoutConstraint activateConstraints:@[
		[_libraryViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[_libraryViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[_libraryViewController.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
		[_libraryViewController.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
	]];
	
	[self.view layoutIfNeeded];
}

- (void)freezeCurrentFace {
	if (_libraryViewController.selectedFaceViewController.dataMode == 3) return;
	[_libraryViewController.selectedFaceViewController freeze];
}

- (BOOL)isFaceStyleRestricted:(NTKFaceStyle)style forDevice:(CLKDevice*)device {
	// Disabled faces for Series 3
	if (device.sizeClass == 1) {
		switch (style) {
			case NTKFaceStyleWhistlerDigital:
			case NTKFaceStyleWhistlerAnalog:
			case NTKFaceStyleWhistlerSubdials:
			case NTKFaceStyleOlympus:
			case NTKFaceStyleSidereal:
			case NTKFaceStyleCalifornia:
			case NTKFaceStyleBlackcomb:
			case NTKFaceStyleSpectrumAnalog:
			case NTKFaceStyleWhitetank:
				return YES;
			default: return NO;
		}
	}
	
	// Globally disabled faces
	switch (style) {
		case NTKFaceStyleUpNext:
			return YES;
		default: return NO;
	}
}

- (void)loadAddableFaceCollection {
	_addableFaceCollection = [[NTKFaceCollection alloc] initWithCollectionIdentifier:@"AddableFaces" deviceUUID:_device.nrDeviceUUID];
	[_addableFaceCollection addObserver:self];
}

- (void)loadLibraryFaceCollection {
	/// TODO: Preferences
	_libraryFaceCollection = [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:@"LibraryFaces" deviceUUID:_device.nrDeviceUUID JSONObjectRepresentation:@{}];
	[_libraryFaceCollection setDebugName:@"clock"];
	[_libraryFaceCollection addObserver:self];
	
#ifndef DISABLE_DEBUG
	for (int i = 0; i <= 42; i++) {
		NTKFace* testFace = [NTKFace defaultFaceOfStyle:i forDevice:_device];
		
		if (!testFace || [self isFaceStyleRestricted:i forDevice:_device]) continue;
		[_libraryFaceCollection appendFace:testFace suppressingCallbackToObserver:nil];
	}
#endif
	
	if (!_libraryFaceCollection.selectedFace) {
		[_libraryFaceCollection setSelectedFaceIndex:0 suppressingCallbackToObserver:nil];
	}
}

- (void)maybeSetOrbEnabled:(BOOL)enabled {
	if (!enabled) {
		[(LWClockView*)self.view setOrbZoomEnabled:enabled];
		return;
	}
	
	if (_faceViewController.dataMode != 1) return;
	
	[(LWClockView*)self.view setOrbZoomEnabled:enabled];
}

- (void)teardownExistingFaceViewControllerIfNeeded {
	if (_faceViewController) {
		[self __removeChildViewController:_faceViewController];
	}
}

- (void)unfreezeCurrentFace {
	[_libraryViewController.selectedFaceViewController unfreeze];
}

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

#pragma mark - LWClockViewDelegate

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	if (!CGRectContainsPoint(self.view.bounds, point)) return nil;
	if (_libraryViewIsPresented) {
		if (!CGRectContainsPoint(_libraryViewController.switcherController.scrollView.frame, point)) {
			return _libraryViewController.switcherController.scrollView;
		}
		return [_libraryViewController.switcherController.view hitTest:point withEvent:event];
	} else if (CGRectContainsPoint(_libraryViewController.switcherController.scrollView.frame, point)) {
		return self.view;
	}
	
	return nil;
}

- (BOOL)isFaceEditing {
	return NO;
}

- (BOOL)isFaceSwitching {
	// return _libraryViewController.isFaceSwitching;
	return NO;
}

- (void)beginZoom {
	// [_faceViewController prepareForOrb];
	
	_libraryViewIsPresented = YES;

	[_libraryViewController beginInteractiveLibraryPresentation];
	_orbZoomActive = YES;
}

- (void)setZoomProgress:(CGFloat)progress {
	[_libraryViewController setInteractiveProgress:progress];
}

- (void)endZoom:(BOOL)completed {
	/// NOTE: arg1=NO -> zoom cancelled
	[_libraryViewController endInteractiveLibraryPresentation];
	
	if (completed) {
		[self maybeSetOrbEnabled:NO];
	} else {
		[_libraryViewController dismissSwitcherAnimated:YES withIndex:_libraryViewController.switcherController.currentPageIndex];
		_libraryViewIsPresented = NO;
	}
	
	[_faceViewController cleanupAfterOrb:completed];
	_orbZoomActive = NO;
}

#pragma mark - LWFaceLibraryViewControllerDelegate

- (void)faceLibraryViewControllerWillCompleteSelection:(LWFaceLibraryViewController*)faceLibraryViewController {
	[(LWClockView*)self.view setOrbZoomEnabled:YES];
	_libraryViewIsPresented = NO;
}

- (void)faceLibraryViewControllerDidCompleteSelection:(LWFaceLibraryViewController*)faceLibraryViewController {
	if (_libraryViewController.selectedFaceViewController != _faceViewController) {
		[self teardownExistingFaceViewControllerIfNeeded];
		_faceViewController = _libraryViewController.selectedFaceViewController;
		
		_libraryViewIsPresented = NO;
	}
}

- (NTKFaceViewController*)faceLibraryViewController:(LWFaceLibraryViewController*)faceLibraryViewController newViewControllerForFace:(NTKFace*)face configuration:(void (^)(NTKFaceViewController*))configuration {
	return [[NTKCompanionFaceViewController alloc] initWithFace:face configuration:configuration];
}

@end