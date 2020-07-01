//
// LWFaceLibraryOverlayView.h
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLKDevice;

@interface LWFaceLibraryOverlayView : UIView {
	CLKDevice* _device;
	UILabel* _leftTitleLabel;
	UILabel* _rightTitleLabel;
	CGFloat _leftTitleAlpha;
	CGFloat _rightTitleAlpha;
	CGFloat _leftTitleOffset;
	CGFloat _rightTitleOffset;
	CGFloat _editTitleLabelWidth;
	CGFloat _cancelTitleLabelWidth;
}

@property (nonatomic, readonly) UIButton* cancelButton;
@property (nonatomic, readonly) UIButton* editButton;
@property (nonatomic, assign) CGFloat luxoButtonWidth;

- (instancetype)initForDevice:(CLKDevice*)device;
- (UIButton*)_newButton;
- (UILabel*)_newTitleLabel;
- (void)setLeftTitle:(nullable NSString*)leftTitle;
- (void)setLeftTitleOffset:(CGFloat)leftTitleOffset alpha:(CGFloat)alpha;
- (void)setRightTitle:(nullable NSString*)rightTitle;
- (void)setRightTitleOffset:(CGFloat)rightTitleOffset alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END