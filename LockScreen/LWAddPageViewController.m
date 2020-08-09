//
// LWAddPageViewController.m
// LockWatch2
//
// Created by janikschmidt on 2/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <objc/runtime.h>
#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>
#import <NTKCustomization/NTKCCLibraryListViewController.h>
#import <NTKCustomization/NTKCCLibraryListCell.h>

#import "LWAddPageActivationButton.h"
#import "LWAddPageViewController.h"

#import "Core/LWAddPageViewControllerDelegate.h"
#import "Core/LWEmulatedCLKDevice.h"

@implementation LWAddPageViewController

- (instancetype)initWithLibraryFaceCollection:(NTKFaceCollection*)libraryFaceCollection addableFaceCollection:(NTKFaceCollection*)addableFaceCollection {
	if (self = [super init]) {
		_device = [CLKDevice currentDevice];
		_libraryFaceCollection = libraryFaceCollection;
		_addableFaceCollection = addableFaceCollection;
		_localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];
		
		_activationButton = [[LWAddPageActivationButton alloc] initWithFrame:(CGRect){{ 0, 0 }, { 57, 57 }}];
		[_activationButton addTarget:self action:@selector(_activationButtonPress) forControlEvents:UIControlEventTouchUpInside];
		
		_faceViewControllers = [NSMutableDictionary dictionary];
	
		[_addableFaceCollection enumerateFacesWithIndexesUsingBlock:^(NTKFace* face, NSUInteger index, BOOL* stop) {
			NTKCompanionFaceViewController* faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face];
		
			[_faceViewControllers setObject:faceViewController forKey:@(index)];
		}];
	}
	
	return self;
}

- (void)loadView {
	UIView* view = [[UIView alloc] initWithFrame:_device.screenBounds];
	[view setClipsToBounds:NO];
	
	self.view = view;
	[view addSubview:_activationButton];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	[_activationButton setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) }];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

#pragma mark - Instance Methods

- (void)_activationButtonPress {
	_active = YES;
	
	UIViewController* containerViewController = [UIViewController new];
		
	_navigationController = [[UINavigationController alloc] initWithRootViewController:containerViewController];
	[_navigationController.navigationBar setTintColor:[UIColor colorWithRed:1.0 green:0.624 blue:0.039 alpha:1.0]];
	
	if (@available(iOS 13, *)) {
		[_navigationController setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
		[_navigationController setModalInPresentation:YES];
	}
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
	[containerViewController.navigationItem setRightBarButtonItem:rightButton];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
		[_localizableBundle localizedStringForKey:@"LIBRARY_WATCH_FACES" value:nil table:nil],
		[_localizableBundle localizedStringForKey:@"LIBRARY_MY_WATCH" value:nil table:nil]
	]];
	[segmentedControl addTarget:self action:@selector(segmentControlDidChange:) forControlEvents: UIControlEventValueChanged];
	[segmentedControl setSelectedSegmentIndex:0];
	[containerViewController.navigationItem setTitleView:segmentedControl];
	
	_addableFacesViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[_addableFacesViewController.view setHidden:NO];
	[_addableFacesViewController.view setFrame:containerViewController.view.bounds];
	[_addableFacesViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[_addableFacesViewController.tableView registerClass:[objc_getClass("NTKCCLibraryListCell") class] forCellReuseIdentifier:[objc_getClass("NTKCCLibraryListCell") reuseIdentifier]];
	[_addableFacesViewController.tableView setDelegate:self];
	[_addableFacesViewController.tableView setDataSource:self];
	
	[containerViewController addChildViewController:_addableFacesViewController];
	[containerViewController.view addSubview:_addableFacesViewController.view];
	
	_libraryFacesViewController = [[objc_getClass("NTKCCLibraryListViewController") alloc] init];
	[_libraryFacesViewController setLibrary:(NTKPersistentFaceCollection*)_libraryFaceCollection];
	[_libraryFacesViewController setEditing:YES animated:NO];
	[_libraryFacesViewController.view setHidden:YES];
	
	[containerViewController addChildViewController:_libraryFacesViewController];
	[containerViewController.view addSubview:_libraryFacesViewController.view];

	[UIApplication.sharedApplication.windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow* window, NSUInteger index, BOOL* stop) {
		if ([window isKindOfClass:NSClassFromString(@"SBCoverSheetWindow")]) {
			[window.rootViewController presentViewController:_navigationController animated:YES completion:nil];
			*stop = YES;
		}
	}];
	
	[_addableFacesViewController.tableView setContentOffset:(CGPoint){ 0, -_addableFacesViewController.tableView.adjustedContentInset.top }];
	[_libraryFacesViewController.tableView setContentOffset:(CGPoint){ 0, -_libraryFacesViewController.tableView.adjustedContentInset.top }];
}

- (NTKCompanionFaceViewController*)_viewControllerForFace:(NTKFace*)face {
	NSUInteger index = [_addableFaceCollection indexOfFace:face];
	NTKCompanionFaceViewController* faceViewController = [_faceViewControllers objectForKey:@(index)];
	
	if (!faceViewController) {
		faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face];
		
		[_faceViewControllers setObject:faceViewController forKey:@(index)];
	}
	
	return faceViewController;
}


- (void)dismiss {
	[self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
	[_navigationController dismissViewControllerAnimated:animated completion:^{
		_active = NO;
		
		[_addableFacesViewController.view removeFromSuperview];
		[_addableFacesViewController removeFromParentViewController];
		
		[_libraryFacesViewController.view removeFromSuperview];
		[_libraryFacesViewController removeFromParentViewController];
		
		_addableFacesViewController = nil;
		_libraryFacesViewController = nil;
	}];
}

- (void)segmentControlDidChange:(UISegmentedControl*)_segmentedControl {
	switch (_segmentedControl.selectedSegmentIndex) {
		case 0:
			[_addableFacesViewController.view setHidden:NO];
			[_libraryFacesViewController.view setHidden:YES];
			break;
		case 1:
			[_addableFacesViewController.view setHidden:YES];
			[_libraryFacesViewController.view setHidden:NO];
			break;
		default: break;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTKCCLibraryListCell* cell = [tableView dequeueReusableCellWithIdentifier:[objc_getClass("NTKCCLibraryListCell") reuseIdentifier] forIndexPath:indexPath];
    
	if (!cell) {
        cell = [[objc_getClass("NTKCCLibraryListCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[objc_getClass("NTKCCLibraryListCell") reuseIdentifier]];
    }
	
	if (indexPath.section == 0) {
		[cell setFaceName:[[_addableFaceCollection faceAtIndex:indexPath.row] name]];
		
		NTKCompanionFaceViewController* faceViewController = [self _viewControllerForFace:[_addableFaceCollection faceAtIndex:indexPath.row]];
		[cell setFaceView:faceViewController.faceView];
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NTKFace* face = [_addableFaceCollection faceAtIndex:indexPath.row];
		[self.delegate addPageViewController:self didSelectFace:face faceViewController:[self _viewControllerForFace:face]];
	}
	
	[self dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return _addableFaceCollection.numberOfFaces;
		case 1:
			return 0;
		default: break;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return [_localizableBundle localizedStringForKey:@"LIBRARY_CUSTOM_INDEV_FOOTER" value:nil table:nil];
		default: break;
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [_localizableBundle localizedStringForKey:@"LIBRARY_APPLE_FACES_HEADER" value:nil table:nil];
		case 1:
			return [_localizableBundle localizedStringForKey:@"LIBRARY_CUSTOM_FACES_HEADER" value:nil table:nil];
		default: break;
	}
	
	return nil;
}

@end