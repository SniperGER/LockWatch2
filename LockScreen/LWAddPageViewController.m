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
#import "Core/LWCustomFaceInterface.h"
#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWPersistentFaceCollection.h"

extern UIColor* NTKCActionColor();

void LWLaunchApplication(NSString* bundleIdentifier, NSURL* url) {
	SBApplication* destinationApplication = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
		
	if (!destinationApplication) return;
	
	SBLockScreenUnlockRequest* request = [NSClassFromString(@"SBLockScreenUnlockRequest") new];
	[request setSource:17];
	[request setIntent:3];
	[request setName:[NSString stringWithFormat:@"SBWorkspaceRequest: Open \"%@\"", bundleIdentifier]];
	[request setDestinationApplication:destinationApplication];
	[request setWantsBiometricPresentation:YES];
	[request setForceAlertAuthenticationUI:YES];
	
	FBSOpenApplicationService* appService = [NSClassFromString(@"FBSOpenApplicationService") serviceWithDefaultShellEndpoint];
	
	[[NSClassFromString(@"SBLockScreenManager") sharedInstance] unlockWithRequest:request completion:^(BOOL completed){
		if (completed) {
			if (url) {
				FBSOpenApplicationOptions* openOptions = [NSClassFromString(@"FBSOpenApplicationOptions") optionsWithDictionary:@{
					@"__PayloadURL": url
				}];
				
				[appService openApplication:bundleIdentifier withOptions:openOptions completion:nil];
			} else {
				[appService openApplication:bundleIdentifier withOptions:nil completion:nil];
			}
		}
	}];
}

@implementation LWAddPageViewController

- (instancetype)initWithLibraryFaceCollection:(NTKFaceCollection*)libraryFaceCollection addableFaceCollection:(NTKFaceCollection*)addableFaceCollection externalFaceCollection:(NTKFaceCollection*)externalFaceCollection {
	if (self = [super init]) {
		// _device = [CLKDevice currentDevice];

		_addableFaceCollection = addableFaceCollection;
		_externalFaceCollection = externalFaceCollection;
		_libraryFaceCollection = libraryFaceCollection;
		
		_localizableBundle = [NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH];
		
		_activationButton = [[LWAddPageActivationButton alloc] initWithFrame:(CGRect){{ 0, 0 }, { 57, 57 }}];
		[_activationButton addTarget:self action:@selector(_activationButtonPress) forControlEvents:UIControlEventTouchUpInside];
		
		_faceViewControllers = [NSMutableDictionary dictionary];
		_externalFaceViewControllers = [NSMutableDictionary dictionary];
	
		[_addableFaceCollection enumerateFacesWithIndexesUsingBlock:^(NTKFace* face, NSUInteger index, BOOL* stop) {
			NTKCompanionFaceViewController* faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face];
		
			[_faceViewControllers setObject:faceViewController forKey:@(index)];
		}];
	}
	
	return self;
}

- (void)loadView {
	UIView* view = [[UIView alloc] initWithFrame:[[CLKDevice currentDevice] screenBounds]];
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

- (NTKCompanionFaceViewController*)_viewControllerForFace:(NTKFace*)face isExternalFace:(BOOL)isExternalFace {
	if (!isExternalFace) {
		NSInteger index = [_addableFaceCollection indexOfFace:face];
		NTKCompanionFaceViewController* faceViewController = [_faceViewControllers objectForKey:@(index)];
	
		if (!faceViewController) {
			faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face forEditing:YES];
			
			[_faceViewControllers setObject:faceViewController forKey:@(index)];
		}
		
		return faceViewController;
	} else {
		NSInteger index = [_externalFaceCollection indexOfFace:face];
		NTKCompanionFaceViewController* faceViewController = [_externalFaceViewControllers objectForKey:@(index)];
	
		if (!faceViewController) {
			faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face forEditing:YES];
			
			[_externalFaceViewControllers setObject:faceViewController forKey:@(index)];
		}
		
		return faceViewController;
	}
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

#pragma mark - Document picker delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
	NSDictionary* faceJSON = [NSDictionary dictionaryWithContentsOfURL:[urls lastObject]];
	
	if (!faceJSON) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[_localizableBundle localizedStringForKey:@"GENERIC_ERROR" value:nil table:nil]
																				 message:[_localizableBundle localizedStringForKey:@"ERROR_INVALID_FACE_JSON" value:nil table:nil]
																		  preferredStyle:UIAlertControllerStyleAlert];
	
		[alertController addAction:[UIAlertAction actionWithTitle:[_localizableBundle localizedStringForKey:@"GENERIC_CONFIRM" value:nil table:nil] style:UIAlertActionStyleDefault handler:nil]];
		
		[self presentViewController:alertController animated:YES completion:nil];
		return;
	}
	
	NTKFace* face = [NTKFace faceWithJSONObjectRepresentation:faceJSON forDevice:[CLKDevice currentDevice]];
	if (!face && [faceJSON objectForKey:@"bundle identifier"]) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[_localizableBundle localizedStringForKey:@"ERROR_MISSING_FACE_TITLE" value:nil table:nil]
																				 message:[_localizableBundle localizedStringForKey:@"ERROR_MISSING_FACE_MESSAGE" value:nil table:nil]
																		  preferredStyle:UIAlertControllerStyleAlert];
		
		[alertController addAction:[UIAlertAction actionWithTitle:[_localizableBundle localizedStringForKey:@"ERROR_MISSING_FACE_INSTALL" value:nil table:nil] style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
				LWLaunchApplication(@"com.saurik.Cydia", [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@", [faceJSON objectForKey:@"bundle identifier"]]]);
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"zbra://"]]) {
				LWLaunchApplication(@"xyz.willy.zebra", [NSURL URLWithString:[NSString stringWithFormat:@"zbra://packages/%@", [faceJSON objectForKey:@"bundle identifier"]]]);
			} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sileo://"]]) {
				LWLaunchApplication(@"org.coolstar.SileoStore", [NSURL URLWithString:[NSString stringWithFormat:@"sileo://package/%@", [faceJSON objectForKey:@"bundle identifier"]]]);
			}
		}]];
		[alertController addAction:[UIAlertAction actionWithTitle:[_localizableBundle localizedStringForKey:@"GENERIC_CANCEL" value:nil table:nil] style:UIAlertActionStyleCancel handler:nil]];
		
		[self presentViewController:alertController animated:YES completion:nil];
		
		return;
	} else if (!face || ([face.class respondsToSelector:@selector(acceptsDevice:)] && ![face.class acceptsDevice:[CLKDevice currentDevice]])) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[_localizableBundle localizedStringForKey:@"ERROR_INCOMPATIBLE_FACE_TITLE" value:nil table:nil]
																				 message:[_localizableBundle localizedStringForKey:@"ERROR_INCOMPATIBLE_FACE_MESSAGE" value:nil table:nil]
																		  preferredStyle:UIAlertControllerStyleAlert];
	
		[alertController addAction:[UIAlertAction actionWithTitle:[_localizableBundle localizedStringForKey:@"GENERIC_CONFIRM" value:nil table:nil] style:UIAlertActionStyleDefault handler:nil]];
		
		[self presentViewController:alertController animated:YES completion:nil];
		
		return;
	}
	
	NTKCompanionFaceViewController* faceViewController = [[NTKCompanionFaceViewController alloc] initWithFace:face forEditing:YES];
	
	[self.delegate addPageViewController:self didSelectFace:face faceViewController:faceViewController];
	[self dismiss];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NTKCFaceDetailActionCell* cell = [[NSClassFromString(@"NTKCFaceDetailActionCell") alloc] initWithAction:2];
		
		[cell.textLabel setText:[_localizableBundle localizedStringForKey:@"IMPORT_WATCH_FACE" value:nil table:nil]];
		[cell.textLabel setTextColor:NTKCActionColor()];
		
		return cell;
	} else {
		NTKCCLibraryListCell* cell = [tableView dequeueReusableCellWithIdentifier:[objc_getClass("NTKCCLibraryListCell") reuseIdentifier] forIndexPath:indexPath];
		
		if (!cell) {
        	cell = [[objc_getClass("NTKCCLibraryListCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[objc_getClass("NTKCCLibraryListCell") reuseIdentifier]];
		}
		
		if (indexPath.section == 1) {
			NTKFace* face = [_addableFaceCollection faceAtIndex:indexPath.row];
			[face applyDefaultConfiguration];
			
			[cell setCurrentFace:NO];
			[cell setFaceName:[face name]];
			
			NTKCompanionFaceViewController* faceViewController = [self _viewControllerForFace:[_addableFaceCollection faceAtIndex:indexPath.row] isExternalFace:NO];
			[cell setFaceView:faceViewController.faceView];
		} else if (indexPath.section == 2) {
			NTKFace<LWCustomFaceInterface>* face = [_externalFaceCollection faceAtIndex:indexPath.row];
			[face applyDefaultConfiguration];
			
			[cell setCurrentFace:YES];
			[cell setFaceName:[face name]];
			[(UILabel*)[cell valueForKey:@"_subtitle"] setText:[face author]];
			
			NTKCompanionFaceViewController* faceViewController = [self _viewControllerForFace:face isExternalFace:YES];
			[cell setFaceView:faceViewController.faceView];
		}
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		UIDocumentPickerViewController* pickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[ @"com.apple.property-list", @"public.data" ] inMode:UIDocumentPickerModeImport];
		[pickerViewController setDelegate:self];
		
		[self presentViewController:pickerViewController animated:YES completion:nil];
	} else {
		if (indexPath.section == 1) {
			NTKFace* face = [_addableFaceCollection faceAtIndex:indexPath.row];
			[self.delegate addPageViewController:self didSelectFace:face faceViewController:[self _viewControllerForFace:face isExternalFace:NO]];
		} else if (indexPath.section == 2) {
			NTKFace* face = [_externalFaceCollection faceAtIndex:indexPath.row];
			[self.delegate addPageViewController:self didSelectFace:face faceViewController:[self _viewControllerForFace:face isExternalFace:YES]];
		}
		
		[self dismiss];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return _addableFaceCollection.numberOfFaces;
		case 2:
			return _externalFaceCollection.numberOfFaces;
		default: break;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2 && !_externalFaceCollection.numberOfFaces) {
		return [_localizableBundle localizedStringForKey:@"LIBRARY_EXTERNAL_FACES_FOOTER" value:nil table:nil];
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return [_localizableBundle localizedStringForKey:@"LIBRARY_APPLE_FACES_HEADER" value:nil table:nil];
		case 2:
			return [_localizableBundle localizedStringForKey:@"LIBRARY_EXTERNAL_FACES_HEADER" value:nil table:nil];
		default: break;
	}
	
	return nil;
}

@end