//
// FaceFixes.xm
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FaceFixes.h"
#import "Tweak.h"

%group SpringBoard
%hook CLKDate
+ (id)unmodifiedDate {
	return [NSDate date];
}
+ (id)date {
	return [NSDate date];
}
+ (id)complicationDate {
	return [NSDate date];
}
%end	/// %hook CLKDate

%hook NTKDate
+ (id)faceDate {
	return [NSDate date];
}
%end	/// %hook NTKDate



%hook ARUIRingsView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook ARUIRingsView

%hook CALayer
%new
- (BOOL)hasSuperviewOfClass:(Class)_class {
	UIView* view = (UIView*)self.delegate;
	
	while (view) {
		if ([view isKindOfClass:_class]) return YES;
		if (![view respondsToSelector:@selector(superview)]) return NO;
		
		view = view.superview;
	}
	
	return NO;
}

- (BOOL)allowsEdgeAntialiasing {
	if ([self hasSuperviewOfClass:%c(NTKFaceView)]) {
		return YES;
	}
	
	return %orig;
}
%end	/// %hook CALayer

%hook CLKDevice
%new
- (CGRect)actualScreenBounds {
	CGFloat screenScale = [(NSNumber*)[self.nrDevice valueForProperty:@"screenScale"] floatValue];
	CGSize screenSize = [[self.nrDevice valueForProperty:@"screenSize"] CGSizeValue];
	
	return (CGRect){
		CGPointZero,
		{ screenSize.width / screenScale, screenSize.height / screenScale }
	};
}

%new
- (CGFloat)actualScreenCornerRadius {
	CGFloat screenScale = [(NSNumber*)[self.nrDevice valueForProperty:@"screenScale"] floatValue];
	CGSize screenSize = [[self.nrDevice valueForProperty:@"screenSize"] CGSizeValue];
	CGRect screenBounds = self.screenBounds;
	
	return (((screenSize.width / screenScale) * (screenSize.height / screenScale)) / (CGRectGetWidth(screenBounds) * CGRectGetHeight(screenBounds))) * self.screenCornerRadius;
}

%new
- (NSDictionary*)JSONObjectRepresentation {
	return @{
		@"_isExplorer": @(self.isExplorer),
		@"_isLuxo": @(self.isLuxo),
		@"_isZeusBlack": @(self.isZeusBlack),
		@"_screenBounds": NSStringFromCGRect(self.screenBounds),
		@"_screenCornerRadius": @(self.screenCornerRadius),
		@"_screenScale": @(self.screenScale),
		@"_sizeClass": @(self.sizeClass),
		@"_supportsTritium": @(self.supportsTritium),
		@"_supportsUrsa": @(self.supportsUrsa),
	};
}
%end	/// %hook CLKDevice

%hook NTKAlbumEmptyView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKAlbumEmptyView

%hook NTKAnalogFaceView
- (void)layoutSubviews {
	%orig;
	
	if (self.contentView) {
		[self.contentView setBackgroundColor:UIColor.clearColor];
	}
}
%end	/// %hook NTKAnalogFaceView

%hook NTKAnalogHandsView
- (void)setOverrideDate:(id)arg1 duration:(CGFloat)arg2 {
	if (![[%c(SBBacklightController) sharedInstance] screenIsOn]) {
		%orig;
		return;
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		%orig;
	}];
}
%end

%hook NTKAnalogScene
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKAnalogScene

%hook NTKAnalogVideoFaceView
- (void)_setVideoPlayerDataSource:(id)arg1 {
	%orig;
	
	[self.videoPlayerView handleStyleDidChange];
}
%end	/// NTKAnalogVideoFaceView

%hook NTKAVListingFaceBaseView
- (void)_handleFaceStyleDidChange {
	if ([self.videoPlayerView playing]) {
		[self.videoPlayerView pause];
	}
	
	[self _cancelAllTasks];
	
	if (self.dataMode == 1) {
		[self _fadeToCurtainViewWithDuration:0.2 completion:^() {
			[self _playNextVideo];
		}];
	} else {
		[self _queuePreloadVideoTask];
		[self setShouldChangeVariantForScreenWake:YES];
	}
}

- (void)_performPreloadVideoTask {
	%orig;
	
	if ([[%c(SBBacklightController) sharedInstance] screenIsOn]) {
		[self _playVideoForScreenWake:nil];
	}
}

- (void)_playVideo {
	if (![self.videoPlayerView playing]) {
		[self _playNextVideo];
	}
}

- (void)_playVideoForScreenWake:(id)arg1 {
	MSHookIvar<BOOL>(self, "_shouldPlayOnWake") = YES;
	
	%orig;
}

- (void)_updatePaused {
	%orig;
	
	if (MSHookIvar<BOOL>(self, "_isPauseLockedout") || MSHookIvar<BOOL>(self, "_isPaused")) return;
	
	if (!MSHookIvar<BOOL>(self, "_isPaused")) {
		if ([[%c(SBBacklightController) sharedInstance] screenIsOn]) {
			MSHookIvar<BOOL>(self, "_shouldPlayOnWake") = NO;
			[self _playVideo];
		} else {
			MSHookIvar<BOOL>(self, "_shouldPlayOnWake") = YES;
			[MSHookIvar<NSTimer*>(self, "_playOnWakeTimeout") invalidate];
			MSHookIvar<NSTimer*>(self, "_playOnWakeTimeout") = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_playVideoForScreenWake:) userInfo:nil repeats:nil];
		}
	} else {
		[self _pauseImmediately];
	}
	
	[self setNeedsLayout];
	MSHookIvar<BOOL>(self, "_updateWhenUnpausing") = NO;
}
%end	/// %hook NTKAVListingFaceBaseView

%hook NTKCircularAnalogDialView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKCircularAnalogDialView

%hook NTKExplorerDialView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook NTKExplorerDialView

%hook NTKFaceView
%new
- (void)_notifyActiveStatusFromOldDataMode:(NSInteger)arg1 newMode:(NSInteger)arg2 {
	if (arg2 <= 1) {
		[self _becameActiveFace];
	} else {
		[self _becameInactiveFace];
	}
}

- (void)setDataMode:(NSInteger)arg1 {
	NSInteger dataMode = MSHookIvar<NSInteger>(self, "_dataMode");
	
	%orig;
	
	if (arg1 != dataMode) {
		[self _notifyActiveStatusFromOldDataMode:dataMode newMode:arg1];
	}
}
%end	/// %hook NTKFaceView

%hook NTKFaceViewController
%property (nonatomic, strong) UIView* backgroundView;

- (id)initWithFace:(id)arg1 configuration:(id /* block */)arg2 {
	id r = %orig;
	
	if ([self isKindOfClass:%c(NTKCompanionFaceViewController)]) return r;

	switch ([[LWPreferences sharedInstance] backgroundType]) {
		case 0: break;
		case 1:
			self.backgroundView = [MTMaterialView materialViewWithRecipe:11 configuration:1 initialWeighting:1];
			break;
		case 2:
			self.backgroundView = [UIView new];
			[self.backgroundView setBackgroundColor:UIColor.blackColor];
			break;
		default: break;
	}
	
	if (self.backgroundView) [self.backgroundView setHidden:YES];
	
	return r;
}

- (void)viewDidLayoutSubviews {
	%orig;
	
	[self.view setClipsToBounds:YES];
	[self.view.layer setCornerRadius:[[CLKDevice currentDevice] screenCornerRadius]];

	if (@available(iOS 13, *)) {
		[self.view.layer setCornerCurve:kCACornerCurveContinuous];
	}
	
	if (![self.view.subviews containsObject:self.backgroundView]) {
		[self.backgroundView removeFromSuperview];
		[self.view insertSubview:self.backgroundView atIndex:0];
	}
	
	if (!CGRectEqualToRect(self.view.bounds, self.backgroundView.bounds)) {
		[self.backgroundView setFrame:self.view.bounds];
	}
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

%new
- (void)setBackgroundViewAlpha:(CGFloat)alpha animated:(BOOL)animated {
	if (!animated) {
		[self.backgroundView setAlpha:alpha];
		return;
	}
	
	[UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.1 options:0 animations:^{
		[self.backgroundView setAlpha:alpha];
	} completion:nil];
}
%end	/// %hook NTKFaceViewController

%hook NTKPrideDigitalFaceView
- (void)layoutSubviews {
	%orig;
	
#if !TARGET_OS_SIMULATOR
	UIView* _bandsView = MSHookIvar<UIView*>(self, "_bandsView");
	[_bandsView removeFromSuperview];
	[self insertSubview:_bandsView atIndex:1];
#endif
}
%end	/// %hook NTKPrideDigitalFaceView

%hook NTKRoundedCornerOverlayView
- (void)layoutSubviews {
	self.hidden = YES;
}
%end	/// %hook NTKRoundedCornerOverlayView

%hook NTKSiderealDialBackgroundView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook NTKSiderealDialBackgroundView

%hook NTKSiderealFaceView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKSiderealFaceView

%hook NTKSolarFaceView
- (void)_becameActiveFace {
	MSHookIvar<NSString*>(self, "_locationManagerToken") = [[NTKLocationManager sharedLocationManager] startLocationUpdatesWithIdentifier:@"ntk.solarFace" handler:^(CLLocation* currentLocation, CLLocation* anyLocation, NSError* error) {
		[self _sharedLocationManagerUpdatedLocation:anyLocation error:error];
	}];
}

- (void)_becameInactiveFace {
	NSString* token = MSHookIvar<NSString*>(self, "_locationManagerToken");
	
	if (token) {
		[[NTKLocationManager sharedLocationManager] stopLocationUpdatesForToken:token];
	}
}
%end	/// %hook NTKSolarFaceView

%hook NTKTimelineDataOperation
- (void)start {
	if (!%c(LWComplicationDataSourceBase) || [[LWPreferences sharedInstance] complicationContent] == 0) return;
	
	%orig;
}
%end	/// %hook NTKTimelineDataOperation

%hook NTKVictoryAnalogBackgroundView
- (id)_dotImage {
	UIImage* r = %orig;
	
	UIGraphicsBeginImageContextWithOptions(r.size, NO, r.scale);
	
	CGRect imageRect = (CGRect){{ 0, 0 }, { r.size.width, r.size.height }};
	[[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:r.size.width / 2] addClip];
	[r drawInRect:imageRect];
	
	UIImage* clippedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return clippedImage;
}

- (void)setBackgroundColor:(UIColor*)arg1 {
	if (CGColorEqualToColor(arg1.CGColor, UIColor.blackColor.CGColor)) {
		%orig(UIColor.clearColor);
	} else {
		%orig;
	}
}
%end	/// %hook NTKVictoryAnalogBackgroundView

%hook NTKVideoPlayerView
- (void)_createVideoPlayerViewIfNeeded {
	if (MSHookIvar<CLKVideoPlayerView*>(self, "_videoPlayerView") == nil) {
		CLKVideoPlayerView* videoPlayerView = [[CLKVideoPlayerView alloc] initWithFrame:self.bounds];
		[videoPlayerView setAutoresizingMask:0x12];
		[videoPlayerView setDelegate:self];
		[videoPlayerView setPausedViewEnabled:self.isPausedViewEnabled];
		
		MSHookIvar<CLKVideoPlayerView*>(self, "_videoPlayerView") = videoPlayerView;
		
	}
}

- (void)_updatePauseState {
	if ([self _shouldPause] != MSHookIvar<BOOL>(self, "_paused")) {
		if ([self _shouldPause]) {
			[self _pause];
		} else {
			if ([MSHookIvar<UIView*>(self, "_posterContainerView") isHidden]) {
				[self _hideCurtainView];
			}
			
			[self _play];
		}
	}
}

- (void)handleStyleDidChange {
	%orig;
	
	[self _playNextVideoForEvent:5 animated:NO];
}
%end	/// NTKVideoPlayerView

%hook NTKUpNextCollectionView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKUpNextCollectionView

%hook SKView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}

- (void)setAllowsTransparency:(BOOL)arg1 {
	%orig(YES);
}
%end	/// %hook SKView
%end	// %group SpringBoard



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [LWPreferences sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				%init(SpringBoard);
			}
		}
	}
}