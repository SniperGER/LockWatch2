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

@interface LWAddPageViewController : UIViewController <UIDocumentPickerDelegate, UITableViewDataSource, UITableViewDelegate> {
	UISegmentedControl* segmentedControl;
	CLKDevice* _device;
	NTKFaceCollection* _libraryFaceCollection;
	NTKFaceCollection* _externalFaceCollection;
	NTKFaceCollection* _addableFaceCollection;
	LWAddPageActivationButton* _activationButton;
	NSMutableDictionary* _faceViewControllers;
	NSMutableDictionary* _externalFaceViewControllers;
	UINavigationController* _navigationController;
	UITableViewController* _addableFacesViewController;
	NTKCCLibraryListViewController* _libraryFacesViewController;
	
	NSBundle* _localizableBundle;
}

@property (nonatomic, readonly, getter=isActive) BOOL active;
@property (nonatomic, weak) id <LWAddPageViewControllerDelegate> delegate;

- (instancetype)initWithLibraryFaceCollection:(NTKFaceCollection*)libraryFaceCollection addableFaceCollection:(NTKFaceCollection*)addableFaceCollection externalFaceCollection:(NTKFaceCollection*)externalFaceCollection;
- (void)loadView;
- (void)viewDidLayoutSubviews;
- (BOOL)_canShowWhileLocked;
- (void)_activationButtonPress;
- (NTKCompanionFaceViewController*)_viewControllerForFace:(NTKFace*)face isExternalFace:(BOOL)isExternalFace;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)segmentControlDidChange:(UISegmentedControl*)segmentedControl;

@end

NS_ASSUME_NONNULL_END