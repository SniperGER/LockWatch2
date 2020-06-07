//
// FaceFixes.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <MaterialKit/MTMaterialView.h>
#import <NanoRegistry/NRDevice.h>
#import <NanoTimeKitCompanion/NTKFace.h>
#import <NanoTimeKitCompanion/NTKFaceView.h>
#import <NanoTimeKitCompanion/NTKFaceViewController.h>

#import "Core/LWPreferences.h"

@interface ARUIRingsView : UIView
@end

@interface CALayer (Private)
 - (BOOL)hasSuperviewOfClass:(Class)_class;
@end

@interface CLKVideoPlayerView : UIView
@end

@interface NTKAnalogFaceView : UIView
@property (nonatomic, retain) UIView *contentView;
@end

@interface NTKFaceViewController (UIEffectView)
// %property
@property (nonatomic, strong) UIView* backgroundView;
// %new
- (void)setBackgroundViewAlpha:(CGFloat)alpha animated:(BOOL)animated;
@end

@interface NTKExplorerDialView : UIView
@end

@interface NTKPrideDigitalFaceView : UIView {
	UIView* _bandsView;
}
@end

@interface NTKRoundedCornerOverlayView : UIView
@end

@interface NTKSiderealDialBackgroundView : UIView
@end