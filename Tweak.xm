#import "Tweak.h"

%hook ACXDeviceConnection
- (void)_onQueue_reEstablishObserverConnectionIfNeeded {
	return;
}
%end	// %hook ACXDeviceConnection

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	clockViewController = [LWClockViewController new];
	
	SBLockScreenManager* manager = [%c(SBLockScreenManager) sharedInstance];
	CSCoverSheetViewController* coverSheet = [manager coverSheetViewController];
	CSMainPageContentViewController* mainPage = [coverSheet mainPageContentViewController];
	
	[mainPage.view addSubview:clockViewController.view];
	[mainPage addChildViewController:clockViewController];
	[clockViewController didMoveToParentViewController:mainPage];
}
%end	// %hook SpringBoard

%hook SBFLockScreenDateView
- (void)layoutSubviews {
	[MSHookIvar<UILabel *>(self,"_timeLabel") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_dateSubtitleView") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_customSubtitleView") removeFromSuperview];
	
	%orig;
	
	[UIView performWithoutAnimation:^{
		[clockViewController.view setFrame:(CGRect){
			CGPointZero,
			{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(clockViewController.view.bounds) }
		}];
		[clockViewController.view setCenter:(CGPoint) {
			CGRectGetMidX(clockViewController.view.bounds),
			CGRectGetMidY(self.frame),
		}];
	}];
}
%end	// %hook SBFLockScreenDateView

%hook CSMainPageContentViewController
- (void)viewDidLayoutSubviews {
	%orig;
	
	[self.view bringSubviewToFront:clockViewController.view];
	
	SBFLockScreenDateViewController* dateViewController = [[[objc_getClass("SBLockScreenManager") sharedInstance] coverSheetViewController] dateViewController];
	
	[UIView performWithoutAnimation:^{
		[clockViewController.view setFrame:(CGRect){
			CGPointZero,
			{ CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(clockViewController.view.bounds) }
		}];
		[clockViewController.view setCenter:(CGPoint) {
			CGRectGetMidX(clockViewController.view.bounds),
			CGRectGetMidY(dateViewController.view.frame),
		}];
	}];
}
%end	// %hook CSMainPageContentViewController



%hook SBBacklightController
- (void)turnOnScreenFullyWithBacklightSource:(NSInteger)arg1 {
	[clockViewController unfreezeCurrentFace];
	
	%orig;
}

- (void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(id /* block */)arg5 {
	if (arg1 == 0.0 && self.screenIsOn) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arg2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[clockViewController freezeCurrentFace];
		});
	}
	
	%orig;
}
%end	// %hook SBBacklightController

%hook CSCoverSheetViewController
- (void)viewDidDisappear:(BOOL)arg1 {
	[clockViewController freezeCurrentFace];
	%orig;
}

- (void)viewWillAppear:(BOOL)arg1 {
	[clockViewController unfreezeCurrentFace];
	%orig;
}
%end	// %hook CSCoverSheetViewController

%ctor {
	if (access(DPKG_PATH, F_OK) == -1 && !TARGET_OS_SIMULATOR) {
		return;
	}
	
	%init();
}