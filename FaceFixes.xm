#import "FaceFixes.h"

%hook NTKDate
+ (id)faceDate {
	return [NSDate date];
}
%end

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
%end



%hook ARUIRingsView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	// %hook ARUIRingsView

%hook CALayer
%new
- (BOOL)hasSuperviewOfClass:(Class)_class {
	UIView* view = (UIView*)self.delegate;
	
	while (view) {
		if ([view isKindOfClass:_class]) {
			return YES;
		}
		
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
%end	// %hook CALayer

%hook CLKDevice
%new
- (CGRect)actualScreenBounds {
	CGFloat screenScale = [[self.nrDevice valueForProperty:@"screenScale"] floatValue];
	CGSize screenSize = [[self.nrDevice valueForProperty:@"screenSize"] CGSizeValue];
	
	return (CGRect){
		CGPointZero,
		{ screenSize.width / screenScale, screenSize.height / screenScale }
	};
}
%end	// %hook CLKDevice

%hook CLKVideoPlayerView
- (void)layoutSubviews {
	%orig;
	
	[self.superview.subviews[2] setBackgroundColor:UIColor.clearColor];
	[self.superview.subviews[3] setBackgroundColor:UIColor.clearColor];
	
	if (self.superview.subviews.count >= 6) {
		[self.superview.subviews[5] setBackgroundColor:UIColor.clearColor];
	}
}
%end	// %hook CLKVideoPlayerView

%hook NTKAlbumEmptyView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKAlbumEmptyView

%hook NTKAnalogFaceView
- (void)layoutSubviews {
	%orig;
	
	if (self.contentView) {
		[self.contentView setBackgroundColor:UIColor.clearColor];
	}
}
%end	// %hook NTKAnalogFaceView

%hook NTKAnalogScene
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKAnalogScene

%hook NTKCircularAnalogDialView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKCircularAnalogDialView

%hook NTKCompanionFaceViewController
%property (nonatomic, strong) UIVisualEffectView* effectView;

- (id)initWithFace:(id)arg1 configuration:(id)arg2 {
	id r = %orig;
	
	self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:17]];
	
	return r;
}

- (void)viewDidLayoutSubviews {
	%orig;
	
	[self.view setClipsToBounds:YES];
	[self.view.layer setCornerRadius:self.face.device.screenCornerRadius];
	
	if (![self.view.subviews containsObject:self.effectView]) {
		[self.view insertSubview:self.effectView atIndex:0];
	}
	
	[self.effectView setFrame:self.view.bounds];
}
%end	// %hook NTKCompanionFaceViewController

%hook NTKComplicationDataSource
+ (Class)dataSourceClassForComplicationType:(unsigned long long)type family:(long long)family forDevice:(id)arg3 {
	return nil;
}
%end	// %hook NTKComplicationDataSource

%hook NTKExplorerDialView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	// %hook NTKExplorerDialView

%hook NTKFaceCollection
- (BOOL)hasLoaded {
	return YES;
}
%end	// %hook NTKFaceCollection

%hook NTKUpNextCollectionView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKUpNextCollectionView

%hook NTKRoundedCornerOverlayView
- (void)layoutSubviews {
	self.hidden = YES;
}
%end	// %hook NTKRoundedCornerOverlayView

%hook NTKSiderealDialBackgroundView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	// %hook NTKSiderealDialBackgroundView

%hook NTKSiderealFaceView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKSiderealFaceView

%hook NTKVictoryAnalogBackgroundView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	// %hook NTKVictoryAnalogBackgroundView

%hook NTKZeusColorPalette
- (UIColor*)backgroundColor {
	return UIColor.clearColor;
}
%end	// %hook NTKZeusColorPalette

%hook SKView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}

- (void)setAllowsTransparency:(BOOL)arg1 {
	%orig(YES);
}
%end	// %hook SKView