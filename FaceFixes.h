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
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "Core/LWPreferences.h"

@interface ARUIRingsView : UIView
@end

@interface CALayer (Private)
 - (BOOL)hasSuperviewOfClass:(Class)_class;
@end

@interface CLKDevice (JSON)
// %new
- (NSDictionary*)JSONObjectRepresentation;
@end

@interface CLKVideoPlayerView : UIView
@end

@interface NTKFaceViewController (UIEffectView)
// %property
@property (nonatomic, strong) UIView* backgroundView;
// %new
- (void)setBackgroundViewAlpha:(CGFloat)alpha animated:(BOOL)animated;
@end

@interface NTKPrideDigitalFaceView : UIView {
	UIView* _bandsView;
}
@end
