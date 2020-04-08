//
// LWFaceLibraryViewController.m
// LockWatch2
//
// Created by janikschmidt on 1/27/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define CLAMP(value, min, max) (value - min) / (max - min)
#define LERP(a, b, value) a + (b - a) * value

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NTKCFaceDetailViewController.h>
#import <NanoTimeKitCompanion/NTKFaceCollection.h>
#import <NanoTimeKitCompanion/NTKFace.h>
#import <NanoTimeKitCompanion/NTKFaceView.h>
#import <NanoTimeKitCompanion/NTKFaceViewController.h>

#import "LWAddPageViewController.h"
#import "LWDeleteConfirmationButton.h"
#import "LWFaceLibraryOverlayView.h"
#import "LWFaceLibraryViewController.h"
#import "LWPageScrollView.h"
#import "LWPageView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWFaceLibraryViewControllerDelegate.h"
#import "Core/LWPersistentFaceCollection.h"

#if __cplusplus
extern "C" {
#endif

NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);

#if __cplusplus
}
#endif

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@implementation LWFaceLibraryViewController

- (instancetype)initWithLibraryCollection:(NTKFaceCollection*)libraryFaceCollection addableCollection:(NTKFaceCollection*)addableFaceCollection {
	if (self = [super init]) {
		_device = [CLKDevice currentDevice];
		
		_libraryFaceCollection = libraryFaceCollection;
		_addableFaceCollection = addableFaceCollection;
		
		_faceViewControllersByFace = [NSMapTable weakToWeakObjectsMapTable];
		_waitingToZoomWhileScrollingToIndex = -1;
		_suspendWorkReasons = [NSMutableSet set];
	}
	
	return self;
}

- (void)didMoveToParentViewController:(nullable UIViewController*)viewController {
	[super didMoveToParentViewController:viewController];
	
	[NSLayoutConstraint activateConstraints:@[
		[_switcherController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[_switcherController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[_switcherController.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
		[_switcherController.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
	]];
	
	[NSLayoutConstraint activateConstraints:@[
		[_libraryOverlayView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[_libraryOverlayView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
		[_libraryOverlayView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
		[_libraryOverlayView.heightAnchor constraintEqualToConstant:CGRectGetHeight(_device.actualScreenBounds)]
	]];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	[self _adjustLibraryOverlayTransform];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];

	LWDeleteConfirmationButton* deleteConfirmationButton = [[LWDeleteConfirmationButton alloc] initWithFrame:CGRectZero];
	[deleteConfirmationButton addTarget:self action:@selector(_confirmDelete) forControlEvents:UIControlEventTouchUpInside];

	_switcherController = [LWSwitcherViewController new];
	
	CGFloat sizeClassFactor = 0;
	switch (_device.sizeClass) {
		case 1:
			sizeClassFactor = 0.6;
			break;
		case 2:
			sizeClassFactor = 0.625;
			break;
		default: break;
	}
	
	[_switcherController setPageWidthWhenZoomedOut:ceilf(
		(CGRectGetWidth(_device.actualScreenBounds) / CGRectGetHeight(_device.actualScreenBounds)) *
		(CGRectGetHeight(_device.actualScreenBounds) * sizeClassFactor)
	)];
	[_switcherController setPageScaleWhenZoomedOut:(_switcherController.pageWidthWhenZoomedOut / CGRectGetWidth(_device.actualScreenBounds))];
	
	[_switcherController setInterpageSpacing:20];
	[_switcherController setInterpageSpacingWhenZoomedIn:20];
	[_switcherController setInterpageSpacingWhenZoomedOut:21];
	[_switcherController setZoomAnimationDuration:0.2];
	
	[_switcherController setDeleteConfirmationView:deleteConfirmationButton];
	[_switcherController setDelegate:self];
	[_switcherController setDataSource:self];
	
	[_switcherController.scrollView setAlwaysBounceHorizontal:YES];
	
	[self addChildViewController:_switcherController];
	[self.view addSubview:_switcherController.view];
	[_switcherController didMoveToParentViewController:self];

	_libraryOverlayView = [[LWFaceLibraryOverlayView alloc] initForDevice:_device];
	[self.view addSubview:_libraryOverlayView];
	
	[_libraryOverlayView.editButton addTarget:self action:@selector(_startFaceEditing) forControlEvents:UIControlEventTouchUpInside];
	[_libraryOverlayView.cancelButton addTarget:self action:@selector(_handleCancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
	
	_presented = YES;
	[self _setPresented:NO];
	
	[_libraryFaceCollection addObserver:self];
	[_addableFaceCollection addObserver:self];
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	[self _scrollToAndSetupFaceAtIndex:_libraryFaceCollection.selectedFaceIndex updateLibraryFaceCollection:NO];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

#pragma mark - Instance Methods

- (LWAddPageViewController*)_addFaceViewController {
	if (!NSClassFromString(@"NTKCCLibraryListCell")) return nil;
	
	if (!_addFaceViewController) {
		_addFaceViewController = [[LWAddPageViewController alloc] initWithLibraryFaceCollection:_libraryFaceCollection addableFaceCollection:_addableFaceCollection];
		[_addFaceViewController setDelegate:self];
	}
	
	return _addFaceViewController;
}

- (void)_adjustLibraryOverlayTransform {
	[_libraryOverlayView setAlpha:CLAMP(_switcherController.zoomLevel, 0.5, 1.0)];
	
	CGFloat baseScale = 1 / _switcherController.pageScaleWhenZoomedOut;
	CGFloat scale = baseScale - ((baseScale - 1) * _switcherController.zoomLevel);
	
	[_libraryOverlayView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

- (void)_animateSwitcherPageDelete {
	[_libraryOverlayView setLeftTitleOffset:0 alpha:0];
	[_libraryOverlayView setRightTitleOffset:0 alpha:1];
	[_libraryOverlayView layoutIfNeeded];
	
	LWPageView* currentPageView = [_switcherController.scrollView pageAtIndex:_switcherController.currentPageIndex];
	[currentPageView setContentAlpha:1.0];
	[currentPageView setOutlineAlpha:1.0];
	
	[self _updateButtonsForSwipeToDeleteFraction:0 pageIndex:_switcherController.currentPageIndex];
}

- (void)_beginSuspendingWorkForReason:(NSString*)reason {
	[_suspendWorkReasons addObject:reason];
}

- (void)_cancelDelete {
	[_switcherController cancelPageDeletionAnimated:YES];
}

- (void)_cancelModalLibraryModification {
	if (!_isZoomingToLibrary && _deleteUnderway) {
		[self _cancelDelete];
	}
}

- (BOOL)_canShowAddPage {
	return _addableFaceCollection && _libraryFaceCollection.numberOfFaces < 18;
}

- (void)_cleanupAfterSwitcherPageDelete {
	[_switcherController setScrollEnabled:YES];
	[self _tearDownDeleteConfirmation];
}

- (void)_configureForSwitcherPageIndex:(NSInteger)index {
	[self _configureForSwitcherScrollFraction:0 lowIndex:index highIndex:-1];
	[_libraryOverlayView.editButton setEnabled:[self _pageIsEditableAtIndex:index]];
}

- (void)_configureForSwitcherScrollFraction:(CGFloat)fraction lowIndex:(NSInteger)lowIndex highIndex:(NSInteger)highIndex {
	CGFloat lowAlpha = 0, highAlpha = 0;
	
	if ([self _isValidSwitcherIndex:lowIndex]) {
		lowAlpha = [self _editButtonAlphaAtPageIndex:lowIndex];
	}
	
	if ([self _isValidSwitcherIndex:lowIndex + 1]) {
		highAlpha = [self _editButtonAlphaAtPageIndex:lowIndex + 1];
	}
	
	[_libraryOverlayView.editButton setAlpha:LERP(lowAlpha, highAlpha, fraction)];
	
	if (_switcherController.zoomedOut) {
		
		[_switcherController.scrollView enumeratePagesWithBlock:^(LWPageView* pageView, NSInteger index, BOOL* stop) {
			if (index == lowIndex) {
				CGFloat _fraction = MIN(MAX(CLAMP(fraction, 0, 0.75), 0), 1);
				
				[pageView setContentAlpha:LERP(1, 0.35, _fraction)];
				[pageView setOutlineAlpha:LERP(1, 0.65, _fraction)];
			} else if (index == lowIndex + 1) {
				CGFloat _fraction = MIN(MAX(CLAMP(fraction, 0.25, 1), 0), 1);
				
				[pageView setContentAlpha:LERP(0.35, 1, _fraction)];
				[pageView setOutlineAlpha:LERP(0.65, 1, _fraction)];
			} else if (pageView.contentAlpha != 0.35 && pageView.outlineAlpha != 0.65) {
				[pageView setContentAlpha:0.35];
				[pageView setOutlineAlpha:0.65];
			}
		}];
	}
	
	if (_presented || _switcherController.animatingZoom) {
		if ([self _isValidSwitcherIndex:lowIndex]) {
			[_libraryOverlayView setLeftTitle:[self _titleForSwitcherPageAtIndex:lowIndex]];
			[_libraryOverlayView setLeftTitleOffset:[self _titleOffsetForSwitcherPageAtIndex:lowIndex] alpha:1 - fraction];
		} else {
			[_libraryOverlayView setLeftTitle:nil];
			[_libraryOverlayView setLeftTitleOffset:0 alpha:0];
		}
		
		if ([self _isValidSwitcherIndex:lowIndex + 1]) {
			[_libraryOverlayView setRightTitle:[self _titleForSwitcherPageAtIndex:lowIndex + 1]];
			[_libraryOverlayView setRightTitleOffset:[self _titleOffsetForSwitcherPageAtIndex:lowIndex + 1] alpha:fraction];
		} else {
			[_libraryOverlayView setRightTitle:nil];
			[_libraryOverlayView setRightTitleOffset:0 alpha:0];
		}
	}
}

- (void)_confirmDelete {
	[_switcherController confirmPageDeletion];
}

- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index {
	[self _dismissSwitcherAnimated:animated withIndex:index completion:nil];
}

- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index completion:(void (^_Nullable)())block {
	[self _dismissSwitcherAnimated:animated withIndex:index remainFrozen:NO completion:block];
}

- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index remainFrozen:(BOOL)remainFrozen completion:(void (^_Nullable)())block {
	if (!_isIncrementallyZooming) {
		if (index == [self _indexOfAddPage]) {
			
		} else {
			[self _selectFaceViewController:[_switcherController pageViewControllerAtIndex:index]];
		}
		
		[self.delegate faceLibraryViewControllerWillCompleteSelection:self];
	
		[_selectedFaceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
			if ([faceViewController.face isKindOfClass:objc_getClass("NTKCharacterFace")]) {
				[faceViewController _setDataMode:0 becomeLiveOnUnfreeze:YES];
			} else {
				[faceViewController _setDataMode:1 becomeLiveOnUnfreeze:YES];
			}
		}];
		
		[_selectedFaceViewController unfreeze];
		[_selectedFaceViewController.view layoutIfNeeded];
		
		[self _zoomInPageAtIndex:index animated:animated completion:^(BOOL finished) {
			[_libraryFaceCollection setSelectedFaceIndex:index suppressingCallbackToObserver:self];
			
			[self.delegate faceLibraryViewControllerDidCompleteSelection:self];
			[self _setPresented:NO];
		}];
	}
}

- (CGFloat)_editButtonAlphaAtPageIndex:(NSInteger)index {
	if (![self _pageIsEditableAtIndex:index]) {
		return 0;
	}
	
	return 1;
}

- (void)_endIncrementalZoomIfPossibleAndNecessary {
	if (![self _isSuspendingWorkForReason:@"SuspendWorkForZooming"] && ![self _isSuspendingWorkForReason:@"SuspendWorkForAnimatingFace"] && _isIncrementallyZooming) {
		[_switcherController endIncrementalZoom];
		_isIncrementallyZooming = NO;
		[self _setPresented:_switcherController.zoomedOut];
		[self _adjustLibraryOverlayTransform];
	}	
}

- (void)_endSuspendingWorkForReason:(NSString*)reason {
	if ([_suspendWorkReasons containsObject:reason]) {
		[_suspendWorkReasons removeObject:reason];
	}
}

- (NSInteger)_indexOfAddPage {
	return _libraryFaceCollection.numberOfFaces;
}

- (BOOL)_isSuspendingWorkForReason:(NSString*)reason {
	return [_suspendWorkReasons containsObject:reason];
}

- (BOOL)_isValidSwitcherIndex:(NSInteger)index {
	if (index >= 0 && _switcherController.scrollView.numberOfPages > index) {
		return YES;
	}
	
	return NO;
}

- (void)_handleCancelButtonPress {
	[self _cancelModalLibraryModification];
}

- (void)_loadAdjacentFaceViewControllers {
	NSInteger currentPageIndex = _switcherController.currentPageIndex;

	if (currentPageIndex != 0 && currentPageIndex < [_libraryFaceCollection numberOfFaces]) {
		NTKFaceViewController* faceViewController = [self _loadFaceViewControllerForFace:[_libraryFaceCollection faceAtIndex:currentPageIndex - 1]];
		[faceViewController configureWithDuration:0.0 block:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:3];
			[faceViewController freeze];
		}];
	}
	
	if (currentPageIndex < [_libraryFaceCollection numberOfFaces]) {
		NTKFaceViewController* faceViewController = [self _loadFaceViewControllerForFace:[_libraryFaceCollection faceAtIndex:currentPageIndex]];
		[faceViewController configureWithDuration:0.0 block:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:3];
			[faceViewController freeze];
		}];
	}
}

- (NTKFaceViewController*)_loadFaceViewControllerForFace:(NTKFace*)face {
	NTKFaceViewController* faceViewController = [_faceViewControllersByFace objectForKey:face];
	
	if (!faceViewController) {
		faceViewController = [self.delegate faceLibraryViewController:self newViewControllerForFace:face configuration:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:3];
		}];
		
		[_faceViewControllersByFace setObject:faceViewController forKey:face];
	}
	
	return faceViewController;
}

- (BOOL)_pageIsEditableAtIndex:(NSInteger)index {
	if (_libraryFaceCollection.numberOfFaces > index) {
		return [[_libraryFaceCollection faceAtIndex:index] isEditable];
	}
	
	return NO;
}

- (LWPageScrollViewController*)_pageScrollViewControllerForCollection:(NTKFaceCollection*)collection {
	if (_libraryFaceCollection == collection) {
		return _switcherController;
	}
	
	return nil;
}

- (void)_prepareForSwitcherPageDelete:(NSInteger)index destinationIndex:(NSInteger)destinationIndex {
	[_switcherController setScrollEnabled:NO];
	
	[_libraryOverlayView setLeftTitle:[self _titleForSwitcherPageAtIndex:index]];
	[_libraryOverlayView setLeftTitleOffset:[self _titleOffsetForSwitcherPageAtIndex:index] alpha:1];
	
	[_libraryOverlayView setRightTitle:[self _titleForSwitcherPageAtIndex:destinationIndex]];
	[_libraryOverlayView setRightTitleOffset:[self _titleOffsetForSwitcherPageAtIndex:destinationIndex] alpha:0];
	
	[_libraryOverlayView layoutIfNeeded];
}

- (void)_scrollToAndSetupFaceAtIndex:(NSInteger)index updateLibraryFaceCollection:(BOOL)updateLibraryFaceCollection {
	[_switcherController.scrollView setTilingSuspended:YES];
	[_switcherController scrollToPageAtIndex:index animated:NO];
	
	if (_selectedFaceViewController) {
		[_selectedFaceViewController configureWithDuration:0.0 block:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:3];
			[_selectedFaceViewController freeze];
		}];
	}
	
	[self _setSelectedFaceViewController:[_switcherController pageViewControllerAtIndex:index]];
	[self _loadAdjacentFaceViewControllers];
	
	[self.delegate faceLibraryViewControllerWillCompleteSelection:self];
	[_selectedFaceViewController configureWithDuration:0.0 block:^(NTKFaceViewController* faceViewController) {
		if ([faceViewController.face isKindOfClass:objc_getClass("NTKCharacterFace")]) {
			[faceViewController _setDataMode:0 becomeLiveOnUnfreeze:YES];
		} else {
			[faceViewController _setDataMode:1 becomeLiveOnUnfreeze:YES];
		}
	}];
	
	[_selectedFaceViewController unfreeze];
	
	if (updateLibraryFaceCollection) {
		[_libraryFaceCollection setSelectedFaceIndex:index suppressingCallbackToObserver:self];
	}
	
	[self.delegate faceLibraryViewControllerDidCompleteSelection:self];
	
	[_switcherController.scrollView setUserInteractionEnabled:NO];
	[_switcherController.scrollView setScrollEnabled:NO];
	
	[self _configureForSwitcherPageIndex:index];
}

- (void)_selectFaceViewController:(NTKFaceViewController*)faceViewController {
	[self _selectFaceViewController:faceViewController withDataMode:3];
}

- (void)_selectFaceViewController:(NTKFaceViewController*)faceViewController withDataMode:(NSInteger)dataMode {
	[faceViewController setDataMode:dataMode];
	[self _setSelectedFaceViewController:faceViewController];
}

- (void)_setAdjacentFacesToDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze {
	NSInteger currentPageIndex = _switcherController.currentPageIndex;
	
	if (currentPageIndex != 0) {
		[self _setFaceAtIndex:currentPageIndex - 1 toDataMode:dataMode andFreeze:freeze];
	}
	
	if (currentPageIndex + 1 < [_libraryFaceCollection numberOfFaces]) {
		[self _setFaceAtIndex:currentPageIndex + 1 toDataMode:dataMode andFreeze:freeze];
	}
}

- (void)_setFaceAtIndex:(NSInteger)index toDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze {
	NTKFaceViewController* faceViewController = [_switcherController pageViewControllerAtIndex:index];
	if ([faceViewController isKindOfClass:objc_getClass("NTKFaceViewController")]) {
		if (freeze) {
			[faceViewController freeze];
		}
		
		[faceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:dataMode];
		}];
		
		if (!freeze) {
			[faceViewController unfreeze];
		}
	}
}

- (void)_setSelectedFaceViewController:(NTKFaceViewController*)faceViewController {
	_selectedFaceViewController = faceViewController;
}

- (void)_setPresented:(BOOL)presented {
	if (presented != _presented) {
		_presented = presented;
		
		[_switcherController.scrollView setUserInteractionEnabled:presented];
		[_switcherController.scrollView setScrollEnabled:presented];
		
		if (_presented) {
			[self showAddPageIfAvailable];
			[_libraryOverlayView.editButton setEnabled:[self _pageIsEditableAtIndex:_switcherController.currentPageIndex]];
			[self _configureForSwitcherPageIndex:_switcherController.currentPageIndex];
		} else {
			[self hideAddPageIfAvailable];
			[_libraryOverlayView.editButton setEnabled:NO];
			
			// Hide the library when CSCoverSheetViewController disappears
			[UIView performWithoutAnimation:^{
				[_switcherController cancelPageDeletionAnimated:NO];
				[self _tearDownDeleteConfirmation];
			}];
		}
	}
}

- (void)_startFaceEditing {
	if (_presented && !_isIncrementallyZooming) {
		if (_switcherController.currentPageIndex < _libraryFaceCollection.numberOfFaces) {
			NTKFace* face = [_libraryFaceCollection faceAtIndex:_switcherController.currentPageIndex];
			
			if ([face isEditable]) {
				NTKCFaceDetailViewController* customizationViewController = [[NTKCFaceDetailViewController alloc] initWithFace:face inGallery:NO];
				
				UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:customizationViewController];
				[navigationController.navigationBar setTintColor:[UIColor colorWithRed:1.0 green:0.624 blue:0.039 alpha:1.0]];
				_editingViewController = navigationController;
				
				UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_stopFaceEditing)];
				customizationViewController.navigationItem.rightBarButtonItem = doneButton;
				
#if __clang_major__ >= 9
				if (@available(iOS 13.0, *)) {
					[navigationController setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
					[navigationController setModalInPresentation:YES];
					
					[customizationViewController setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
				}
#endif
				
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
				[UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
#pragma GCC diagnostic pop
			}
		}
	}
}

- (void)_stopFaceEditing {
	[self _stopFaceEditing:YES];
}

- (void)_stopFaceEditing:(BOOL)animated {
	[_editingViewController dismissViewControllerAnimated:animated completion:^ {
		[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
	}];
}

- (void)_tearDownDeleteConfirmation {
	_deleteUnderway = NO;
	
	[_libraryOverlayView.cancelButton setHidden:YES];
	[_libraryOverlayView.cancelButton setTransform:CGAffineTransformIdentity];
}

- (NSString*)_titleForSwitcherPageAtIndex:(NSInteger)index {
	if (_libraryFaceCollection.numberOfFaces > index) {
		NTKFace* face = [_libraryFaceCollection faceAtIndex:index];
		
		return [face.name uppercaseString];
	} else if ([self _indexOfAddPage] == index) {
		return NTKClockFaceLocalizedString(@"NEW_FACE", @"NEW");
	}
	
	return nil;
}

- (CGFloat)_titleOffsetForSwitcherPageAtIndex:(NSInteger)index {
	return (CGRectGetWidth(_switcherController.scrollView.bounds) * index) - _switcherController.scrollView.contentOffset.x;
}

- (void)_updateButtonsForSwipeToDeleteFraction:(CGFloat)fraction pageIndex:(NSInteger)index {
	[_libraryOverlayView.editButton setAlpha:MIN(MAX([self _editButtonAlphaAtPageIndex:index] - CLAMP(fraction, 0.0, 0.6), 0), 1)];
	
	CGFloat translation = MIN(MAX(CLAMP(fraction, 0.4, 1.0), 0), 1);
	[_libraryOverlayView.cancelButton setTransform:CGAffineTransformMakeTranslation(0, CGRectGetHeight(_libraryOverlayView.cancelButton.bounds) * (1 - translation))];
	[_libraryOverlayView.cancelButton setAlpha:translation];
}

- (void)_zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))block {
	[self _beginSuspendingWorkForReason:@"SuspendWorkForZooming"];
	[_switcherController zoomInPageAtIndex:index animated:animated withAnimations:^{
		[self _adjustLibraryOverlayTransform];
	} completion:^(BOOL finished){
		if (block) {
			block(finished);
		}
		
		[self _endSuspendingWorkForReason:@"SuspendWorkForZooming"];
	}];
}


- (void)activateWithSelectedFaceViewController:(NTKFaceViewController*)faceViewController {
	if (faceViewController) {
		[self _setSelectedFaceViewController:faceViewController];
		[_faceViewControllersByFace setObject:faceViewController forKey:faceViewController.face];
		
		[_switcherController.scrollView setTilingSuspended:NO];
		[_switcherController setDataSource:self];
		[_switcherController scrollToPageAtIndex:[_libraryFaceCollection indexOfFace:_selectedFaceViewController.face] animated:NO];
	}
	
	_active = 1;
}

- (void)beginInteractiveLibraryPresentation {
	_isIncrementallyZooming = YES;
	
	if (_switcherControllerNeedsReload) {
		[_switcherController reloadPages];
		_switcherControllerNeedsReload = NO;
	}
	
	[self.view layoutIfNeeded];
	[self _beginSuspendingWorkForReason:@"SuspendWorkForZooming"];
	
	[_switcherController beginIncrementalZoom];
	[self _setPresented:YES];
}

- (void)commitToLibraryPresentation {
	[self _beginSuspendingWorkForReason:@"SuspendWorkForAnimatingFace"];
	
	[_selectedFaceViewController configureWithDuration:0.3 block:^(NTKFaceViewController* faceViewController) {
		[faceViewController setDataMode:3];
	}];
	[_selectedFaceViewController freezeAfterDelay:0.4];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self _endSuspendingWorkForReason:@"SuspendWorkForAnimatingFace"];
		[self _endIncrementalZoomIfPossibleAndNecessary];
	});
}

- (void)endInteractiveLibraryPresentation {
	[self _endSuspendingWorkForReason:@"SuspendWorkForZooming"];
	[self _endIncrementalZoomIfPossibleAndNecessary];
}

- (void)hideAddPageIfAvailable {
	// if (_switcherController.scrollView.numberOfPages == _libraryFaceCollection.numberOfFaces + 1) {
	// 	[_switcherController.scrollView performSuppressingScrollCallbacks:^{
	// 		[_switcherController.scrollView deletePageAtIndex:[self _indexOfAddPage] animated:NO updateModel:NO];
	// 	}];
	// }
}

- (void)setInteractiveProgress:(CGFloat)progress {
	[_switcherController setIncrementalZoomLevel:progress];
	[self _adjustLibraryOverlayTransform];
}

- (void)showAddPageIfAvailable {
	if (_switcherController.scrollView.numberOfPages != _libraryFaceCollection.numberOfFaces) return;
	if (![self _canShowAddPage]) return;
	
	[_switcherController.scrollView insertPageAtIndex:_libraryFaceCollection.numberOfFaces];
}

#pragma mark - NTKFaceCollectionObserver

- (void)faceCollection:(NTKFaceCollection *)collection didAddFace:(NTKFace *)arg2 atIndex:(NSUInteger)arg3 {
	NSLog(@"did add face");
}

- (void)faceCollection:(NTKFaceCollection *)collection didRemoveFace:(NTKFace *)face atIndex:(NSUInteger)index {
	LWPageScrollViewController* pageScrollViewController = [self _pageScrollViewControllerForCollection:collection];
	[pageScrollViewController.scrollView deletePageAtIndex:index animated:NO updateModel:NO];
	
	if (_libraryFaceCollection == collection) {
		if (collection.numberOfFaces > 0) {
			[_switcherController scrollToPageAtIndex:[self _indexOfAddPage] animated:NO];
		}
		
		[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
	}
}

- (void)faceCollectionDidReorderFaces:(NTKFaceCollection *)collection {
	LWPageScrollViewController* pageScrollViewController = [self _pageScrollViewControllerForCollection:collection];
	[pageScrollViewController reloadPages];
	
	[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
}

#pragma mark - LWAddPageViewControllerDelegate

- (void)addPageViewController:(LWAddPageViewController*)addPageViewController didSelectFace:(NTKFace*)face faceViewController:(NTKFaceViewController*)faceViewController {
	if (_addFaceViewController == addPageViewController) {
		if (_addFaceViewController.isActive) {
			if (faceViewController) {
				[_addableFaceCollection replaceFaceLocallyByCopy:face suppressingCallbackToObserver:self];
				
				[face setCreationDate:[NSDate date]];
				[face setOrigin:5];
				[face setEditedState:YES];
				[_libraryFaceCollection appendFace:face suppressingCallbackToObserver:self];
				
				faceViewController = [self _loadFaceViewControllerForFace:face];
				
				if (faceViewController) {
					[self _selectFaceViewController:faceViewController];
				}
				
				[_switcherController reloadPages];
				[self _dismissSwitcherAnimated:NO withIndex:[_libraryFaceCollection indexOfFace:face]];
			}
		}
	}
}

#pragma mark - LWPageScrollViewControllerDataSource

- (UIViewController*)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController viewControllerForPageAtIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		if (index != [self _indexOfAddPage]) {
			return [self _loadFaceViewControllerForFace:[_libraryFaceCollection faceAtIndex:index]];
		} else {
			return [self _addFaceViewController];
		}
	}
	
	return nil;
}

- (NSInteger)pageScrollViewControllerNumberOfPages:(LWPageScrollViewController*)pageScrollViewController {
	if (_switcherController == pageScrollViewController) {
		if (_libraryFaceCollection.numberOfFaces != 0) {
			if ([self _canShowAddPage] && _presented && NSClassFromString(@"NTKCCLibraryListCell")) {
				return _libraryFaceCollection.numberOfFaces + 1;
			}
			
			return _libraryFaceCollection.numberOfFaces;
		}
	}
	
	return 0;
}

#pragma mark - LWPageScrollViewControllerDelegate

- (BOOL)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController canDeletePageAtIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		if (_switcherController.currentPageIndex == index) {
			if ([self _indexOfAddPage] == index) {
				return NO;
			} else {
				return [_libraryFaceCollection numberOfFaces] > 1;
			}
		}
	}
	
	return NO;
}

- (BOOL)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController canSelectPageAtIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		return [self _indexOfAddPage] != index;
	}
	
	return YES;
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController configurePage:(LWPageView*)pageView atIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		[pageView setOutlineStrokeWidth:3];
		[pageView setOutlineCornerRadius:_device.actualScreenCornerRadius + 8];
		[pageView setOutlineInsets:(UIEdgeInsets){ -8, -8, -8, -8 }];
	}
}

- (CGSize)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController contentViewSizeForPageAtIndex:(NSInteger)index {
	if (self.view) {
		return _device.screenBounds.size;
	}
	
	return CGSizeZero;
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didBeginSwipeToDeleteAtIndex:(NSInteger)index {
	_deleteUnderway = YES;
	
	[_libraryOverlayView.cancelButton setHidden:NO];
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didDeletePageAtIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		if (_libraryFaceCollection.numberOfFaces > index) {
			[_libraryFaceCollection removeFaceAtIndex:index suppressingCallbackToObserver:self];
			[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
		}
	}
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didEndSwipeToDeleteAtIndex:(NSInteger)index deleted:(BOOL)deleted {
	if (!deleted) {
		[self _tearDownDeleteConfirmation];
	}
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didScrollToPageAtIndex:(NSInteger)index toDeleteIndex:(NSInteger)deleteIndex {
	if (_switcherController == pageScrollViewController) {
		[_libraryFaceCollection setSelectedFaceIndex:index suppressingCallbackToObserver:self];
		[_libraryFaceCollection removeFaceAtIndex:deleteIndex suppressingCallbackToObserver:self];
		[(LWPersistentFaceCollection*)_libraryFaceCollection synchronize];
	}
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didSelectPageAtIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		[self _dismissSwitcherAnimated:YES withIndex:index];
	}
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didUpdateSwipeToDeleteAtIndex:(NSInteger)index fraction:(CGFloat)fraction {
	[self _updateButtonsForSwipeToDeleteFraction:fraction pageIndex:index];
}

- (NSInteger)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController scrollDirectionForDeletedIndex:(NSInteger)index {
	if (_switcherController == pageScrollViewController) {
		if (index + 1 < [self _indexOfAddPage]) {
			return 0;
		}
		
		return 1;
	}
	
	return 0;
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController willAnimatePageDeletion:(NSInteger)index destinationIndex:(NSInteger)destinationIndex {
	if (_switcherController == pageScrollViewController) {
		[self _prepareForSwitcherPageDelete:index destinationIndex:destinationIndex];
	}
}

- (void)pageScrollViewControllerDidAnimatePageDeletion:(LWPageScrollViewController*)pageScrollViewController {
	if (_switcherController == pageScrollViewController) {
		[self _cleanupAfterSwitcherPageDelete];
	}
}

- (void)pageScrollViewControllerDidScroll:(LWPageScrollViewController*)pageScrollViewController {
	if (!_switcherController.animatingZoom) {
		CGFloat fraction = 0;
		NSInteger lowPageIndex = -1, highPageIndex = -1;
		
		[pageScrollViewController.scrollView getCurrentScrollFraction:&fraction lowPageIndex:&lowPageIndex highPageIndex:&highPageIndex];
		
		if (_switcherController == pageScrollViewController) {
			[self _configureForSwitcherScrollFraction:fraction lowIndex:lowPageIndex highIndex:-1];
		}
	}
}

- (void)pageScrollViewControllerDidStartScrolling:(LWPageScrollViewController*)pageScrollViewController {
	[self _beginSuspendingWorkForReason:@"SuspendWorkForScrolling"];
	
	if (_switcherController == pageScrollViewController) {
		_switcherStartingPageIndex = [_switcherController currentPageIndex];
		[_libraryOverlayView.editButton setEnabled:NO];
		
		if (_presented) {
			[_switcherController.scrollView setTilingSuspended:YES];
			
			_isFaceSwitching = YES;
		}
	}
}

- (void)pageScrollViewControllerDidStopScrolling:(LWPageScrollViewController*)pageScrollViewController {
	[self _endSuspendingWorkForReason:@"SuspendWorkForScrolling"];
	
	_isFaceSwitching = NO;
	
	[_switcherController.scrollView setTilingSuspended:NO];
	
	if (_waitingToZoomWhileScrollingToIndex != -1) {
		[_switcherController setScrollEnabled:YES];
		
		if (_waitingToZoomWhileScrollingToIndex != [self _indexOfAddPage] || _addFaceViewController.isActive) {
			[self _dismissSwitcherAnimated:YES withIndex:_waitingToZoomWhileScrollingToIndex completion:nil];
			
			_waitingToZoomWhileScrollingToIndex = -1;
		}
	}
	
	if (_switcherController == pageScrollViewController) {
		if (_switcherController.scrollView.numberOfPages != 0) {
			if (_presented) {
				[self _configureForSwitcherPageIndex:_switcherController.scrollView.currentPageIndex];
			} else {
				if (_switcherController.scrollView.currentPageIndex == _libraryFaceCollection.selectedFaceIndex) {
					
				} else {
					[self _scrollToAndSetupFaceAtIndex:_switcherController.scrollView.currentPageIndex updateLibraryFaceCollection:YES];
				}
			}
		}
	}
}

- (void)pageScrollViewControllerIsAnimatingPageDeletion:(LWPageScrollViewController*)pageScrollViewController {
	if (_switcherController == pageScrollViewController) {
		[self _animateSwitcherPageDelete];
	}
}

@end