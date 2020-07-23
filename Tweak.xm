//
// Tweak.xm
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FaceFixes.h"
#import "Tweak.h"

%group SpringBoard
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	clockViewController = [LWClockViewController new];
	
	if (!clockViewController) {
		NSBundle* localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];

		UIAlertController* alert = [UIAlertController alertControllerWithTitle:[localizableBundle localizedStringForKey:@"NO_DEVICE_TITLE" value:nil table:nil]
																	   message:[localizableBundle localizedStringForKey:@"NO_DEVICE_MESSAGE" value:nil table:nil]
																preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CONFIRM" value:nil table:nil] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
#pragma GCC diagnostic pop
		
		return;
	}
}
%end	/// %hook SpringBoard

%hook SBFLockScreenDateView
- (void)layoutSubviews {
	if (clockViewController) {
		[MSHookIvar<UILabel *>(self,"_timeLabel") removeFromSuperview];
		[MSHookIvar<UILabel *>(self,"_dateSubtitleView") removeFromSuperview];
		[MSHookIvar<UILabel *>(self,"_customSubtitleView") removeFromSuperview];
	}
	
	%orig;
	
	SBLockScreenManager* manager = [%c(SBLockScreenManager) sharedInstance];
	CSCoverSheetViewController* coverSheetController = [manager coverSheetViewController];
	
	// TODO: Fix delayed layout
	// [coverSheetController viewDidLayoutSubviews];
	[clockViewController layoutForDateViewController:[coverSheetController dateViewController] withEffectiveInterfaceOrientation:coverSheetController.effectiveInterfaceOrientation];
}

- (void)setAlignmentPercent:(CGFloat)arg1 {
	[clockViewController setAlignmentPercent:arg1];
	
	return;
}

- (void)setLegibilitySettings:(_UILegibilitySettings*)arg1 {
	%orig;
	
	[LWClockViewController setLegibilitySettings:arg1];
}
%end	/// %hook SBFLockScreenDateView

%hook CSMainPageContentViewController
- (void)viewDidLayoutSubviews {
	%orig;
	
	if (self.view.subviews.count && clockViewController.view.superview != self.view.subviews[0]) {
		[clockViewController.view removeFromSuperview];
		[self.view.subviews[0] addSubview:clockViewController.view];
	}
}
%end	/// %hook CSMainPageContentViewController

%hook CSCombinedListViewController
- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	if (clockViewController.view.superview != self.view) {
		[clockViewController.view removeFromSuperview];
		[self.view addSubview:clockViewController.view];
	}
}
%end	/// %hook CSCombinedListViewController

%hook CSCoverSheetViewController
- (void)viewWillAppear:(BOOL)arg1 {
	if ([[%c(SBBacklightController) sharedInstance] screenIsOn]) {
		[clockViewController.faceViewController handleOrdinaryScreenWake];
		[clockViewController unfreezeCurrentFace];
	}
	
	[clockViewController layoutForDateViewController:[self dateViewController] withEffectiveInterfaceOrientation:self.effectiveInterfaceOrientation];
	
	%orig;
}

- (void)viewDidDisappear:(BOOL)arg1 {
	[clockViewController dismissFaceLibraryAnimated:NO];
	[clockViewController freezeCurrentFace];
	[clockViewController.faceViewController handleScreenBlanked];
	
	%orig;
}

- (void)viewDidLayoutSubviews {
	%orig;
	
	if (!clockViewController.view.superview) return;
	[clockViewController layoutForDateViewController:[self dateViewController] withEffectiveInterfaceOrientation:self.effectiveInterfaceOrientation];
}

- (void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
	if (preferences.batteryChargingViewHidden) return;

	%orig;
}

- (void)finishUIUnlockFromSource:(int)arg1 {
	%orig;
	
	[clockViewController dismissCustomizationViewControllers:YES];
}
%end	/// %hook CSCoverSheetViewController

%hook SBBacklightController
- (void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(id /* block */)arg5 {
	if (arg1 == 0.0 && self.screenIsOn) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arg2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[clockViewController dismissFaceLibraryAnimated:NO];
			[clockViewController dismissCustomizationViewControllers:NO];
			
			[clockViewController freezeCurrentFace];
			[clockViewController.faceViewController handleScreenBlanked];
		});
	}
	
	%orig;
}

- (void)_startFadeOutAnimationFromLockSource:(int)arg1 {
#ifdef DEMO_MODE
	return;
#else
	if (clockViewController.isIncrementallyZooming || clockViewController.faceLibraryIsPresented) {
		return;
	}
#endif
	
	%orig;
}

- (void)turnOnScreenFullyWithBacklightSource:(NSInteger)arg1 {
	if (arg1 == 20) {
		[clockViewController.faceViewController handleWristRaiseScreenWake];
	} else {
		[clockViewController.faceViewController handleOrdinaryScreenWake];
	}
	
	[clockViewController unfreezeCurrentFace];
	
	%orig;
}
%end	/// %hook SBBacklightController

static CGFloat notificationOffset = 0;

%hook CSCombinedListViewController
- (UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets r = %orig;
    
	BOOL isiPhoneLandscape = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIWindow isLandscapeOrientation];
	if (isiPhoneLandscape) return r;
	
	SBFLockScreenDateViewController* dateViewController = [[[objc_getClass("SBLockScreenManager") sharedInstance] coverSheetViewController] dateViewController];
	CLKDevice* device = [CLKDevice currentDevice];
	
	if (notificationOffset == 0 && !CGRectIsEmpty([(SBFLockScreenDateView*)dateViewController.view restingFrame]) && !isnan(CGRectGetHeight(device.actualScreenBounds))) {
		notificationOffset = (CGRectGetMinY([(SBFLockScreenDateView*)dateViewController.view restingFrame]) + CGRectGetHeight(device.actualScreenBounds) + 12) - r.top;
	}
	
	r.top += notificationOffset;
    
    return r;
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;

	[self _updateListViewContentInset];
}

- (CGFloat)_minInsetsToPushDateOffScreen {
	BOOL isiPhoneLandscape = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIWindow isLandscapeOrientation];
	if (isiPhoneLandscape) return %orig;
	
	return %orig + notificationOffset;
}
%end	/// %hook CSCombinedListViewController

%hook _CSPaddingView
- (CGSize)paddingSize {
	return CGSizeZero;
}

- (void)setPaddingSize:(CGSize)arg1 {
	%orig(CGSizeZero);
}
%end	/// %hook _CSPaddingView

static BOOL scrollEnabled = YES;

%hook NTKCFaceDetailViewController
- (BOOL)_canShowWhileLocked {
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	scrollEnabled = YES;
	%orig;
}

- (void)viewDidLayoutSubviews {
	CGPoint contentOffset = self.tableView.contentOffset;
	
	%orig;
	[self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
	
	if (scrollEnabled) {
		[self.tableView setContentOffset:(CGPoint){ 0, MIN(-self.tableView.adjustedContentInset.top, contentOffset.y) }];
	}
}

- (NSInteger)numberOfSectionsInTableView:(id)arg1 {
	return %orig - 1;
}
%end	/// %hook NTKCFaceDetailViewController

%hook NTKCFaceDetailEditOptionCell
- (void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2 {
	scrollEnabled = NO;
	%orig;
}
%end	/// %hook NTKCFaceDetailEditOptionCell

%hook NTKCFaceDetailComplicationPickerCell
- (void)pickerView:(id)arg1 didSelectRow:(NSInteger)arg2 inComponent:(NSInteger)arg3 {
	scrollEnabled = NO;
	%orig;
}
%end	/// %hook NTKCFaceDetailEditOptionCell

%hook NTKCCLibraryListViewController
- (void)viewWillAppear:(BOOL)arg1 {
	scrollEnabled = YES;
	return;
}

- (void)viewDidLayoutSubviews {
	%orig;
	
	[self.tableView setContentInset:self.tableView.safeAreaInsets];
	
	if (scrollEnabled) {
		[self.tableView setContentOffset:(CGPoint){ 0, -self.tableView.adjustedContentInset.top }];
		scrollEnabled = NO;
	}
}
%end	/// %hook NTKCCLibraryListViewController


%hook BSUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
#ifdef DEMO_MODE
	return %orig(nil, nil);
#else
	return %orig;
#endif	
}
%end	/// %hook BSUICAPackageView

%hook CSTeachableMomentsContainerViewController
- (void)_addHomeAffordanceAnimation {
#ifdef DEMO_MODE
	return;
#else
	%orig;
#endif
}

- (void)_addHomeAffordanceResetAnimation {
#ifdef DEMO_MODE
	return;
#else
	%orig;
#endif
}

- (void)_addTextAnimation {
#ifdef DEMO_MODE
	return;
#else
	%orig;
#endif
}

- (void)_addTextResetAnimation {
#ifdef DEMO_MODE
	return;
#else
	%orig;
#endif
}
%end

%hook CSFixedFooterView
- (void)layoutSubviews {
#ifdef DEMO_MODE
	[self setHidden:YES];
	return;
#else
	%orig;
#endif
}
%end
%end	// %group SpringBoard



%group Bridge
%hook COSSettingsListController
- (void)viewDidLoad {
	%orig;
	
	NSBundle* localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];

	PSSpecifier* syncSpecifier = [PSSpecifier preferenceSpecifierNamed:[localizableBundle localizedStringForKey:@"SYNC_TO_LOCK_SCREEN" value:nil table:nil] target:self set:nil get:nil detail:nil cell:13 edit:nil];
	[syncSpecifier setButtonAction:@selector(syncToLockscreen)];
	[self insertSpecifier:syncSpecifier atIndex:4];
}

%new
- (void)syncToLockscreen {
	NSBundle* localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];
	
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[localizableBundle localizedStringForKey:@"SYNC_TO_LOCK_SCREEN" value:nil table:nil]
																			 message:[localizableBundle localizedStringForKey:@"SYNC_TO_LOCK_SCREEN_PROMPT" value:nil table:nil]
																	  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CANCEL" value:nil table:nil] style:UIAlertActionStyleCancel handler:nil];
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CONFIRM" value:nil table:nil] style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ml.festival.lockwatch2/SyncLibrary" object:nil userInfo:@{
			@"faceJSON": self.facesController.library.JSONObjectRepresentation
		}];
	}];
	
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	[self presentViewController:alertController animated:YES completion:nil];
}
%end	/// %hook COSSettingsListController

%hook NTKCFaceDetailViewController
- (void)_addTapped {
	NSBundle* localizableBundle = [NSBundle bundleWithPath:@"/Library/Application Support/LockWatch2"];
	
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[localizableBundle localizedStringForKey:@"ADD_TO_PROMPT" value:nil table:nil] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	CLKDevice* clkDevice = [CLKDevice currentDevice];
	NRDevice* nrDevice = [clkDevice nrDevice];
	
	UIAlertAction* watchAction = [UIAlertAction actionWithTitle:[nrDevice valueForProperty:@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		%orig;
	}];
	UIAlertAction* lockScreenAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"ADD_TO_LOCK_SCREEN" value:nil table:nil] style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ml.festival.lockwatch2/AddToLibrary" object:nil userInfo:@{
			@"faceJSON": self.face.JSONObjectRepresentation
		}];
	}];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[localizableBundle localizedStringForKey:@"GENERIC_CANCEL" value:nil table:nil] style:UIAlertActionStyleCancel handler:nil];
	
	[alertController addAction:watchAction];
	[alertController addAction:lockScreenAction];
	[alertController addAction:cancelAction];
	[self presentViewController:alertController animated:YES completion:nil];
}
%end	/// %hook NTKCFaceDetailViewController
%end	// %group Bridge



%group PhotonFixes
%hook PhotonScreenManager
- (void)setIsShowing:(BOOL)arg1 {
	%orig;
	
	CSCoverSheetViewController* coverSheetController = [[objc_getClass("SBLockScreenManager") sharedInstance] coverSheetViewController];
	SBFLockScreenDateViewController* dateViewController = [coverSheetController dateViewController];
	
	if ([dateViewController respondsToSelector:@selector(ptnFaceViewController)] && dateViewController.ptnFaceViewController != nil) {
		[(LWClockView*)clockViewController.view setAlpha:arg1 ? 0 : 1 animated:YES];
	} else {
		[clockViewController.faceViewController setBackgroundViewAlpha:arg1 ? 0 : 1 animated:YES];
	}
}
%end	/// %hook PhotonScreenManager
%end	// %group PhotonFixes



%hook ACXDeviceConnection
- (void)_onQueue_reEstablishObserverConnectionIfNeeded {
	return;
}
%end	// %hook ACXDeviceConnection

%hook REElementDataSourceController
- (void)_queue_reloadWithQOS:(unsigned int)arg1 qosOffset:(int)arg2 forceReload:(BOOL)arg3 completion:(id /* block */)arg4 {
	return;
}
%end	// %hook REElementDataSourceController



#if !TARGET_OS_SIMULATOR
static BOOL (*old_NTKShowHardwareSpecificFaces)();
BOOL _NTKShowHardwareSpecificFaces() {
	return YES;
}
#endif

static void LWEmulatedWatchTypeChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
	[preferences reloadPreferences];
	
	LWEmulatedCLKDevice* currentDevice = [LWEmulatedCLKDevice currentDevice];
	
	if (preferences.isEmulatingDevice) {
		NSDictionary* watchData = [[NSDictionary alloc] initWithContentsOfFile:WATCH_DATA_PATH][preferences.emulatedDeviceType];

		LWEmulatedNRDevice* nrDevice = [[LWEmulatedNRDevice alloc] initWithJSONObjectRepresentation:watchData[@"registry"] pairingID:[NSUUID new]];
		
		LWEmulatedCLKDevice* device = [[LWEmulatedCLKDevice alloc] initWithJSONObjectRepresentation:watchData[@"device"] forNRDevice:nrDevice];
		
		if ([currentDevice respondsToSelector:@selector(physicalDevice)] && currentDevice.physicalDevice) {
			[device setPhysicalDevice:currentDevice.physicalDevice];
		} else if (currentDevice.nrDevice) {
			[device setPhysicalDevice:currentDevice];
		}
		
		[CLKDevice setCurrentDevice:device];
	} else if (currentDevice) {
		NSDictionary* watchData = [[CLKDevice currentDevice] JSONObjectRepresentation];
		
		NRDevice* nrDevice = [currentDevice nrDevice];
		
		LWEmulatedCLKDevice* device = [[LWEmulatedCLKDevice alloc] initWithJSONObjectRepresentation:watchData forNRDevice:nrDevice];
		
		if ([currentDevice respondsToSelector:@selector(physicalDevice)] && currentDevice.physicalDevice) {
			[device setPhysicalDevice:currentDevice.physicalDevice];
		} else if (currentDevice.nrDevice) {
			[device setPhysicalDevice:currentDevice];
		}
		
		[CLKDevice setCurrentDevice:device];
	}
	
	if (clockViewController) {
		[clockViewController setDevice:[CLKDevice currentDevice]];
		
		[clockViewController loadAddableFaceCollection];
		[clockViewController loadLibraryFaceCollection];
		[clockViewController _createOrRecreateFaceContent];
		
		notificationOffset = 0;
	}
}



%ctor {
	@autoreleasepool {
		// File integrity check
		if (access(DPKG_PATH, F_OK) == -1 && !TARGET_OS_SIMULATOR) {
			NSLog(@"[LockWatch] You are using LockWatch 2 from a source other than https://repo.festival.ml");
			NSLog(@"[LockWatch] To ensure system stability and security (or what's left of it, thanks to your jailbreak), LockWatch 2 will disable itself now.");
			
			return;
		}
		
		preferences = [LWPreferences sharedInstance];
		
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
	#if !TARGET_OS_SIMULATOR
				MSHookFunction(((void*)MSFindSymbol(NULL, "_NTKShowHardwareSpecificFaces")),(void*)_NTKShowHardwareSpecificFaces, (void**)&old_NTKShowHardwareSpecificFaces);
	#endif
				
				void* customizationBundle = dlopen("/System/Library/NanoPreferenceBundles/Customization/NTKCustomization.bundle/NTKCustomization", RTLD_LAZY);
				if (!customizationBundle) {
					NSLog(@"Could not load customization bundle. Watch face management will be partly unavailable.");
				}
				
				void* complicationsLib = dlopen("/Library/MobileSubstrate/DynamicLibraries/LockWatch2Complications.dylib", RTLD_LAZY);
				if (!complicationsLib) {
					NSLog(@"Disabling complications.");
				}
				
				CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, LWEmulatedWatchTypeChanged, CFSTR("ml.festival.lockwatch2/WatchSelected"), NULL, CFNotificationSuspensionBehaviorCoalesce);
				LWEmulatedWatchTypeChanged(NULL, NULL, NULL, NULL, NULL);
				
				%init(SpringBoard);
				
				void* photonPtr = dlopen("/Library/MobileSubstrate/DynamicLibraries/Photon.dylib", RTLD_NOW);
				if (photonPtr) {
					%init(PhotonFixes);
				}
			}
			
			if ([bundleIdentifier isEqualToString:@"com.apple.Bridge"]) {
				%init(Bridge);
			}
		}
	}
}