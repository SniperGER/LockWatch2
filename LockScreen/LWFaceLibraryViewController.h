//
// LWFaceLibraryViewController.h
// LockWatch2
//
// Created by janikschmidt on 1/27/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

#import <NanoTimeKitCompanion/NTKFaceCollectionObserver-Protocol.h>

#import "Core/LWAddPageViewControllerDelegate.h"
#import "Core/LWPageScrollViewControllerDataSource.h"
#import "Core/LWPageScrollViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LWFaceLibraryViewControllerDelegate;
@class CLKDevice, LWAddPageViewController, LWFaceLibraryOverlayView, LWSwitcherViewController, NTKFaceCollection, NTKFaceViewController;

@interface LWFaceLibraryViewController : UIViewController <LWAddPageViewControllerDelegate, LWPageScrollViewControllerDataSource, LWPageScrollViewControllerDelegate, NTKFaceCollectionObserver> {
	CLKDevice* _device;
	NTKFaceCollection* _libraryFaceCollection;
	NTKFaceCollection* _externalFaceCollection;
    NTKFaceCollection* _addableFaceCollection;
	LWSwitcherViewController* _switcherController;
    LWAddPageViewController* _addFaceViewController;
	BOOL _switcherControllerNeedsReload;
	NSInteger _waitingToZoomWhileScrollingToIndex;
    NSMapTable* _faceViewControllersByFace;
	BOOL _isIncrementallyZooming;
    BOOL _presented;
    BOOL _active;
    NSMutableSet* _suspendWorkReasons;
	NSInteger _switcherStartingPageIndex;
	BOOL _deleteUnderway;
	BOOL _isZoomingToLibrary;
	CGPoint _previousSwitcherScrollOffset;
	UINavigationController* _editingViewController;
	UIActivityViewController* _greenfieldSharingController;
}

@property (nonatomic, readonly) BOOL isFaceSwitching;
@property (nonatomic, readonly) LWAddPageViewController* addFaceViewController;
@property (nonatomic, readonly) LWFaceLibraryOverlayView* libraryOverlayView;
@property (nonatomic, readonly) LWSwitcherViewController* switcherController;
@property (nonatomic) BOOL isFaceEditing;
@property (nonatomic, readonly) BOOL presented;
@property (nonatomic, readonly) NTKFaceViewController* selectedFaceViewController;
@property (nonatomic, weak) id <LWFaceLibraryViewControllerDelegate> _Nullable delegate;

- (instancetype)initWithLibraryCollection:(NTKFaceCollection*)libraryFaceCollection addableCollection:(NTKFaceCollection*)addableFaceCollection externalFaceCollection:(NTKFaceCollection*)externalFaceCollection;
- (void)didMoveToParentViewController:(nullable UIViewController*)viewController;
- (void)viewDidLayoutSubviews;
- (void)viewDidLoad;
- (BOOL)_canShowWhileLocked;
- (LWAddPageViewController*)_addFaceViewController;
- (void)_adjustLibraryOverlayTransform;
- (void)_animateSwitcherPageDelete;
- (void)_beginSuspendingWorkForReason:(NSString*)reason;
- (void)_cancelDelete;
- (void)_cancelModalLibraryModification;
- (BOOL)_canShowAddPage;
- (void)_cleanupAfterSwitcherPageDelete;
- (void)_configureForSwitcherPageIndex:(NSInteger)index;
- (void)_configureForSwitcherScrollFraction:(CGFloat)fraction lowIndex:(NSInteger)lowIndex highIndex:(NSInteger)highIndex;
- (void)_confirmDelete;
- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index;
- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index completion:(void (^_Nullable)())block;
- (void)_dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index remainFrozen:(BOOL)remainFrozen completion:(void (^_Nullable)())block;
- (CGFloat)_editButtonAlphaAtPageIndex:(NSInteger)index;
- (void)_endIncrementalZoomIfPossibleAndNecessary;
- (void)_endSuspendingWorkForReason:(NSString*)reason;
- (NSInteger)_indexOfAddPage;
- (BOOL)_isSuspendingWorkForReason:(NSString*)reason;
- (BOOL)_isValidSwitcherIndex:(NSInteger)index;
- (void)_handleCancelButtonPress;
- (void)_loadAdjacentFaceViewControllers;
- (NTKFaceViewController*)_loadFaceViewControllerForFace:(NTKFace*)face;
- (BOOL)_pageIsEditableAtIndex:(NSInteger)index;
- (LWPageScrollViewController*)_pageScrollViewControllerForCollection:(NTKFaceCollection*)collection;
- (void)_prepareForSwitcherPageDelete:(NSInteger)index destinationIndex:(NSInteger)destinationIndex;
- (void)_scrollToAndSetupFaceAtIndex:(NSInteger)index updateLibraryFaceCollection:(BOOL)updateLibraryFaceCollection;
- (void)_selectFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)_selectFaceViewController:(NTKFaceViewController*)faceViewController withDataMode:(NSInteger)dataMode;
- (void)_setAdjacentFacesToDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze;
- (void)_setFaceAtIndex:(NSInteger)index toDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze;
- (void)_setSelectedFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)_setPresented:(BOOL)presented;
- (void)_startFaceEditing;
- (void)_stopFaceEditing;
- (void)_stopFaceEditing:(BOOL)animated;
- (void)_tearDownDeleteConfirmation;
- (NSString*)_titleForSwitcherPageAtIndex:(NSInteger)index;
- (CGFloat)_titleOffsetForSwitcherPageAtIndex:(NSInteger)index;
- (void)_updateButtonsForSwipeToDeleteFraction:(CGFloat)fraction pageIndex:(NSInteger)index;
- (void)_zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))block;
- (void)activateWithSelectedFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)beginInteractiveLibraryPresentation;
- (void)commitToLibraryPresentation;
- (void)endInteractiveLibraryPresentation;
- (void)hideAddPageIfAvailable;
- (BOOL)isIncrementallyZooming;
- (void)setInteractiveProgress:(CGFloat)progress;
- (void)showAddPageIfAvailable;

@end

NS_ASSUME_NONNULL_END