//
//  LWFaceLibraryViewController.m
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <objc/runtime.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NTKFace.h>
#import <NanoTimeKitCompanion/NTKFaceCollection.h>
#import <NanoTimeKitCompanion/NTKFaceViewController.h>

#import "LWFaceLibraryOverlayView.h"
#import "LWFaceLibraryViewController.h"
#import "LWPageScrollView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedDevice.h"
#import "Core/LWFaceLibraryViewControllerDelegate.h"

@interface LWFaceLibraryViewController () {
	BOOL _isIncrementallyZooming;
}

@end

@implementation LWFaceLibraryViewController

- (id)initWithLibraryCollection:(NTKFaceCollection*)libraryFaceCollection addableCollection:(NTKFaceCollection*)addableFaceCollection {
	if (self = [super init]) {
		_device = [CLKDevice currentDevice];
		
		_libraryFaceCollection = libraryFaceCollection;
		_addableFaceCollection = addableFaceCollection;
		
		_faceViewControllersByFace = [NSMapTable weakToWeakObjectsMapTable];
		
		_suspendWorkReasons = [NSMutableSet set];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	/// TODO: Delete Confirmation View
	
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
	
	[_switcherController setDataSource:self];
	[_switcherController setDelegate:self];
	
	// [_switcherController.scrollView setAlwaysBounceHorizontal:YES];
	
	[self addChildViewController:_switcherController];
	[self.view addSubview:_switcherController.view];
	
	_libraryOverlayView = [[LWFaceLibraryOverlayView alloc] initForDevice:_device];
	[_libraryOverlayView setDistanceBetweenLabels:(_switcherController.pageWidthWhenZoomedOut + _switcherController.interpageSpacingWhenZoomedOut)];
	[self.view addSubview:_libraryOverlayView];
	
	[_libraryFaceCollection enumerateFacesWithIndexesUsingBlock:^(NTKFace* face, NSUInteger index, BOOL* stop) {
		[_libraryOverlayView addTitle:[(NSString*)face._defaultName uppercaseString] forIndex:index];
	}];
	
	_presented = YES;
	[self setPresented:NO];
	
	[_addableFaceCollection addObserver:self];
	[_libraryFaceCollection addObserver:self];
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	[self scrollToAndSetupFaceAtIndex:_libraryFaceCollection.selectedFaceIndex updateLibraryFaceCollection:NO];
	_isFaceSwitching = NO;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	[self adjustLibraryOverlayTransform];
}

- (void)didMoveToParentViewController:(UIViewController*)viewController {
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
		[_libraryOverlayView.widthAnchor constraintEqualToConstant:_libraryOverlayView.distanceBetweenLabels],
		[_libraryOverlayView.heightAnchor constraintEqualToConstant:CGRectGetHeight(_device.actualScreenBounds)]
	]];
}

#pragma mark - Instance Methods

- (void)activateWithSelectedFaceViewController:(NTKFaceViewController*)faceViewController {

}

- (void)adjustLibraryOverlayTransform {
	[_libraryOverlayView setAlpha:_switcherController.zoomLevel];
	
	CGFloat baseScale = 1 / _switcherController.pageScaleWhenZoomedOut;
	CGFloat scale = baseScale - ((baseScale - 1) * _switcherController.zoomLevel);
	
	[_libraryOverlayView setTransform:CGAffineTransformMakeScale(scale, scale)];
}

- (void)beginInteractiveLibraryPresentation {
	_isIncrementallyZooming = YES;
	// [self setIsFaceEditing:NO];
	
	[self.view layoutIfNeeded];
	
	[self beginSuspendingWorkForReason:@"SuspendWorkForZooming"];
	[self commitToLibraryPresentation];
	[self setAdjacentFacesToDataMode:3 andFreeze:NO];
	
	[_switcherController beginIncrementalZoom];
	[_libraryOverlayView scrollToLabelAtIndex:_switcherController.scrollView.currentPageIndex animated:NO];
	
	[self setPresented:YES];
}

- (void)beginSuspendingWorkForReason:(NSString*)reason {
	[_suspendWorkReasons addObject:reason];
}

- (void)commitToLibraryPresentation {
	[_selectedFaceViewController configureWithDuration:0.3 block:^(NTKFaceViewController* faceViewController) {
		[_selectedFaceViewController setDataMode:3];
	}];
	[_selectedFaceViewController freezeAfterDelay:0.4];
	
	[self setAdjacentFacesToDataMode:3 andFreeze:YES];
}

- (void)dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index {
	[self dismissSwitcherAnimated:animated withIndex:index completion:nil];
}

- (void)dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index completion:(id /* block */)completion {
	if (!_isIncrementallyZooming) {
		if (index == [self indexOfAddPage]) {
			
		} else {
			[self selectFaceViewController:[_switcherController pageViewControllerAtIndex:index]];
		}
		
		[self.delegate faceLibraryViewControllerWillCompleteSelection:self];
	
		// [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
			[_selectedFaceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
				if ([faceViewController.face isKindOfClass:objc_getClass("NTKCharacterFace")]) {
					[faceViewController _setDataMode:0 becomeLiveOnUnfreeze:YES];
				} else {
					[faceViewController _setDataMode:1 becomeLiveOnUnfreeze:YES];
				}
			}];
		// }];
		
		[_selectedFaceViewController unfreeze];
		[_selectedFaceViewController.view layoutIfNeeded];
		
		[self zoomInPageAtIndex:index animated:YES completion:^(BOOL finished) {
			[_libraryFaceCollection setSelectedFaceIndex:index suppressingCallbackToObserver:self];
			
			[self.delegate faceLibraryViewControllerDidCompleteSelection:self];
			[self setPresented:NO];
		}];
	}
}

- (void)endIncrementalZoomIfPossibleAndNecessary {
	if (![self isSuspendingWorkForReason:@"SuspendWorkForZooming"]) {
		if (_isIncrementallyZooming) {
			[_switcherController endIncrementalZoom];
			_isIncrementallyZooming = NO;
			
			[self setPresented:[_switcherController zoomedOut]];
		}
	}
}

- (void)endInteractiveLibraryPresentation {
	[self endSuspendingWorkForReason:@"SuspendWorkForZooming"];
	[self endIncrementalZoomIfPossibleAndNecessary];
}

- (void)endSuspendingWorkForReason:(NSString*)reason {
	if ([_suspendWorkReasons containsObject:reason]) {
		[_suspendWorkReasons removeObject:reason];
	}
}

- (NSInteger)indexOfAddPage {
	// return [_libraryFaceCollection numberOfFaces];
	return -1;
}

- (BOOL)isSuspendingWorkForReason:(NSString*)reason {
	return [_suspendWorkReasons containsObject:reason];
}

- (NTKFaceViewController*)loadFaceViewControllerForFace:(NTKFace*)face {
	NTKFaceViewController* controller = [_faceViewControllersByFace objectForKey:face];
	
	if (!controller) {
		controller = [self.delegate faceLibraryViewController:self newViewControllerForFace:face configuration:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:3];
		}];
	}
	
	return controller;
}

- (id)pageScrollViewControllerForCollection:(NTKFaceCollection*)collection {
	if (collection == _libraryFaceCollection) {
		return _switcherController;
	} else if (collection == _addableFaceCollection) {
		return nil;
	}
	
	return nil;
}

- (void)scrollToAndSetupFaceAtIndex:(NSInteger)index updateLibraryFaceCollection:(BOOL)updateLibraryFaceCollection {
	[_switcherController scrollToPageAtIndex:index animated:NO];
	
	__block NSInteger dataMode = (_selectedFaceViewController.dataMode == 2 ? 1 : 0) + 1;
	[_selectedFaceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
		[faceViewController setDataMode:3];
	}];
	[_selectedFaceViewController freeze];
	
	[self setSelectedFaceViewController:[_switcherController pageViewControllerAtIndex:_switcherController.scrollView.currentPageIndex]];
	
	// [self loadAdjacentFaceViewControllers];
	[_selectedFaceViewController unfreeze];
	
	[self.delegate faceLibraryViewControllerWillCompleteSelection:self];
	
	[_selectedFaceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
		[faceViewController setDataMode:dataMode];
	}];
	
	if (updateLibraryFaceCollection) {
		[_libraryFaceCollection setSelectedFaceIndex:index suppressingCallbackToObserver:self];
	}
	
	[_libraryOverlayView scrollToLabelAtIndex:index animated:NO];
	
	[self.delegate faceLibraryViewControllerDidCompleteSelection:self];
	[_switcherController.scrollView setUserInteractionEnabled:YES];
	[_switcherController.scrollView setBounces:YES];
	[_switcherController.scrollView setScrollEnabled:YES];
	
	// [self configureForSwitcherPageIndex:index];
}

- (void)selectFaceViewController:(NTKFaceViewController*)faceViewController {
	[self selectFaceViewController:faceViewController withDataMode:3];
}

- (void)selectFaceViewController:(NTKFaceViewController*)faceViewController withDataMode:(NSInteger)dataMode {
	[faceViewController setDataMode:dataMode];
	[faceViewController.view layoutIfNeeded];
	
	[self setSelectedFaceViewController:faceViewController];
}

- (void)setAdjacentFacesToDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze {
	NSInteger currentPageIndex = _switcherController.currentPageIndex;
	
	if (currentPageIndex != 0) {
		[self setFaceAtIndex:currentPageIndex - 1 toDataMode:dataMode andFreeze:freeze];
	}
	
	if (currentPageIndex + 1 < [_libraryFaceCollection numberOfFaces]) {
		[self setFaceAtIndex:currentPageIndex + 1 toDataMode:dataMode andFreeze:freeze];
	}
}

- (void)setFaceAtIndex:(NSInteger)index toDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze {
	NTKFaceViewController* faceViewController = [_switcherController pageViewControllerAtIndex:index];
	if ([faceViewController isKindOfClass:objc_getClass("NTKFaceViewController")]) {
		if (!freeze) {
			[faceViewController unfreeze];
		}
		
		[faceViewController configureWithDuration:0 block:^(NTKFaceViewController* faceViewController) {
			[faceViewController setDataMode:dataMode];
		}];
		
		if (freeze) {
			[faceViewController freeze];
		}
	}
}

- (void)setInteractiveProgress:(CGFloat)progress {
	[_switcherController setIncrementalZoomLevel:progress];
	[self adjustLibraryOverlayTransform];
}

- (void)setPresented:(BOOL)presented {
	if (presented != _presented) {
		_presented = presented;
		
		if (_presented) {
			// showAddPageIfAvailable
			// libraryOverlayView.editButton setEnabled:_pageIsEditableAtIndex
		} else {
			// hideAddPageIfAvailable
			// libraryOverlayView.editButton setEnabled:NO
		}
	}
}

- (void)setSelectedFaceViewController:(NTKFaceViewController*)faceViewController {
	_selectedFaceViewController = faceViewController;
}

- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
	[_switcherController zoomInPageAtIndex:index animated:animated withAnimations:^{
		[self adjustLibraryOverlayTransform];
	} completion:completion];
}

#pragma mark - LWPageScrollViewControllerDataSource

- (UIViewController*)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController viewControllerForPageAtIndex:(NSInteger)index {
	if (pageScrollViewController == _switcherController) {
		if (!_presented || self.indexOfAddPage != index) {
			return [self loadFaceViewControllerForFace:[_libraryFaceCollection faceAtIndex:index]];
		}
		
		// return _addFaceViewController
	}
	
	return nil;
}

- (NSInteger)pageScrollViewControllerNumberOfPages:(LWPageScrollViewController*)pageScrollViewController {
	if (pageScrollViewController != _switcherController) {
		return [_addableFaceCollection numberOfFaces];
	} else {
		return [_libraryFaceCollection numberOfFaces] + 1;
		// return [_libraryFaceCollection numberOfFaces];
	}
}

#pragma mark - LWPageScrollViewControllerDelegate

- (void)pageScrollViewControllerDidScroll:(LWPageScrollViewController*)pageScrollViewController {
	if (_switcherController != pageScrollViewController) {
		
	} else {
		// CGFloat scrollFraction = _switcherController.scrollView.contentOffset.x / _switcherController.scrollView.contentSize.width;
		// [_libraryOverlayView setContentOffset:(CGPoint){ scrollFraction * _libraryOverlayView.contentSize.width, 0 }];
		
		[_libraryOverlayView setContentOffset:_switcherController.scrollView.contentOffset];
	}
}

- (CGSize)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController contentViewSizeForPageAtIndex:(NSInteger)index {
	return self.view.bounds.size;
}

- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didSelectPageAtIndex:(NSInteger)index {
	if (_switcherController != pageScrollViewController) {
		
	} else {
		[self dismissSwitcherAnimated:YES withIndex:index];
	}
}

@end