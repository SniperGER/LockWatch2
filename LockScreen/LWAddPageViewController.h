//
// LWAddPageViewController.h
// LockWatch2
//
// Created by janikschmidt on 2/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LWAddPageViewControllerDelegate;
@class CLKDevice, LWAddPageActivationButton, NTKCCLibraryListViewController, NTKCompanionFaceViewController, NTKFaceCollection;

@interface LWAddPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	CLKDevice* _device;
	NTKFaceCollection* _libraryFaceCollection;
	NTKFaceCollection* _addableFaceCollection;
	LWAddPageActivationButton* _activationButton;
	NSMapTable* _faceViewControllers;
	UINavigationController* _navigationController;
	UITableViewController* _addableFacesViewController;
	NTKCCLibraryListViewController* _libraryFacesViewController;
	
	NSBundle* _prefBundle;
}

@property (nonatomic, readonly, getter=isActive) BOOL active;
@property (nonatomic, weak) id <LWAddPageViewControllerDelegate> delegate;

- (instancetype)initWithLibraryFaceCollection:(NTKFaceCollection*)libraryFaceCollection addableFaceCollection:(NTKFaceCollection*)addableFaceCollection;
- (void)loadView;
- (void)viewDidLayoutSubviews;
- (BOOL)_canShowWhileLocked;
- (void)_activationButtonPress;
- (NTKCompanionFaceViewController*)_viewControllerForFace:(NTKFace*)face;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)segmentControlDidChange:(UISegmentedControl*)segmentedControl;

@end

NS_ASSUME_NONNULL_END