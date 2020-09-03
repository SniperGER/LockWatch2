//
// LWFaceLibraryOverlayView.h
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLKDevice, SBUILegibilityLabel;

@interface LWFaceLibraryOverlayView : UIView {
	CLKDevice* _device;
	SBUILegibilityLabel* _leftTitleLabel;
	SBUILegibilityLabel* _rightTitleLabel;
	CGFloat _leftTitleAlpha;
	CGFloat _rightTitleAlpha;
	CGFloat _leftTitleOffset;
	CGFloat _rightTitleOffset;
}

@property (nonatomic, readonly) UIButton* cancelButton;
@property (nonatomic, readonly) UIButton* editButton;
@property (nonatomic, readonly) UIButton* shareButton;

- (instancetype)initForDevice:(CLKDevice*)device;
- (void)_legibilitySettingsChanged;
- (UIButton*)_newEditOrCancelButton;
- (UIButton*)_newShareButton;
- (SBUILegibilityLabel*)_newTitleLabel;
- (void)setLeftTitle:(nullable NSString*)leftTitle;
- (void)setLeftTitleOffset:(CGFloat)leftTitleOffset alpha:(CGFloat)alpha;
- (void)setRightTitle:(nullable NSString*)rightTitle;
- (void)setRightTitleOffset:(CGFloat)rightTitleOffset alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END