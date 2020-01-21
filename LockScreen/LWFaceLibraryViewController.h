//
//  LWFaceLibraryViewController.h
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core/LWPageScrollViewControllerDataSource.h"
#import "Core/LWPageScrollViewControllerDelegate.h"

@protocol LWFaceLibraryViewControllerDelegate;
@class CLKDevice, LWAddPageViewController, LWFaceLibraryOverlayView, LWSwitcherViewController, NTKFace, NTKFaceCollection, NTKFaceViewController;

@interface LWFaceLibraryViewController : UIViewController <LWPageScrollViewControllerDataSource, LWPageScrollViewControllerDelegate> {
	CLKDevice* _device;
	BOOL _active;
	BOOL _presented;
	NTKFaceCollection* _addableFaceCollection;
	NTKFaceCollection* _libraryFaceCollection;
	NSMapTable* _faceViewControllersByFace;
	LWSwitcherViewController* _switcherController;
	LWAddPageViewController* _addFaceViewController;
	LWFaceLibraryOverlayView* _libraryOverlayView;
	NSMutableSet* _suspendWorkReasons;
}

@property (nonatomic, readonly) LWSwitcherViewController* switcherController;
@property (nonatomic, readonly) LWAddPageViewController* addFaceViewController;
@property (nonatomic, readonly) LWFaceLibraryOverlayView* libraryOverlayView;
@property (nonatomic, readonly) BOOL isFaceReordering;
@property (nonatomic, readonly) BOOL isFaceSwitching;
@property (nonatomic) BOOL isFaceEditing;
@property (nonatomic, readonly) NTKFaceViewController* selectedFaceViewController;
@property (nonatomic) id <LWFaceLibraryViewControllerDelegate> delegate;

- (id)initWithLibraryCollection:(NTKFaceCollection*)libraryFaceCollection addableCollection:(NTKFaceCollection*)addableFaceCollection;
- (void)activateWithSelectedFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)adjustLibraryOverlayTransform;
- (void)beginInteractiveLibraryPresentation;
- (void)beginSuspendingWorkForReason:(NSString*)reason;
- (void)commitToLibraryPresentation;
- (void)dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index;
- (void)dismissSwitcherAnimated:(BOOL)animated withIndex:(NSInteger)index completion:(id /* block */)completion;
- (void)endIncrementalZoomIfPossibleAndNecessary;
- (void)endInteractiveLibraryPresentation;
- (void)endSuspendingWorkForReason:(NSString*)reason;
- (NSInteger)indexOfAddPage;
- (BOOL)isSuspendingWorkForReason:(NSString*)reason;
- (NTKFaceViewController*)loadFaceViewControllerForFace:(NTKFace*)face;
- (id)pageScrollViewControllerForCollection:(NTKFaceCollection*)collection;
- (void)scrollToAndSetupFaceAtIndex:(NSInteger)index updateLibraryFaceCollection:(BOOL)updateLibraryFaceCollection;
- (void)selectFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)selectFaceViewController:(NTKFaceViewController*)faceViewController withDataMode:(NSInteger)dataMode;
- (void)setAdjacentFacesToDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze;
- (void)setFaceAtIndex:(NSInteger)index toDataMode:(NSInteger)dataMode andFreeze:(BOOL)freeze;
- (void)setInteractiveProgress:(CGFloat)progress;
- (void)setPresented:(BOOL)presented;
- (void)setSelectedFaceViewController:(NTKFaceViewController*)faceViewController;
- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end