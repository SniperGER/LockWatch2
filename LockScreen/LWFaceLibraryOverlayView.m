//
// LWFaceLibraryOverlayView.m
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "Core/LWEmulatedCLKDevice.h"

#import "LWFaceLibraryOverlayButton.h"
#import "LWFaceLibraryOverlayView.h"

#if __cplusplus
extern "C" {
#endif

NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);

#if __cplusplus
}
#endif

@implementation LWFaceLibraryOverlayView

- (instancetype)initForDevice:(CLKDevice*)device {
	if (self = [super initWithFrame:device.actualScreenBounds]) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setClipsToBounds:NO];
		
		_device = device;
		
		_leftTitleLabel = [self _newTitleLabel];
		[self addSubview:_leftTitleLabel];
		
		_rightTitleLabel = [self _newTitleLabel];
		[self addSubview:_rightTitleLabel];
		
		_editButton = [self _newButton];
		[_editButton setAdjustsImageWhenDisabled:NO];
		[_editButton setTitle:NTKClockFaceLocalizedString(@"EDIT_FACE", @"Customize") forState:UIControlStateNormal];
		[_editButton.titleLabel sizeToFit];
		
		_editTitleLabelWidth = CGRectGetWidth(_editButton.titleLabel.bounds);
		[self addSubview:_editButton];
		
		_cancelButton = [self _newButton];
		[_cancelButton setTitle:NTKClockFaceLocalizedString(@"CANCEL_ADD_FACE", @"Cancel") forState:UIControlStateNormal];
		[_cancelButton setHidden:YES];
		[_cancelButton.titleLabel sizeToFit];
		
		_cancelTitleLabelWidth = CGRectGetWidth(_cancelButton.titleLabel.bounds);
		[self addSubview:_cancelButton];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat mainScreenHeight = [[_device.nrDevice valueForProperty:@"mainScreenHeight"] floatValue];
	CGFloat verticalOffset = 0;
	
	if (mainScreenHeight <= 340) {
		verticalOffset = 1.5;
	} else if (mainScreenHeight <= 390 || mainScreenHeight <= 394) {
		verticalOffset = 3.5;
	} else if (mainScreenHeight <= 448) {
		verticalOffset = 6;
	}
	
	[_leftTitleLabel setCenter:(CGPoint){
		CGRectGetMidX(self.bounds) + _leftTitleOffset,
		CGRectGetMidY(_leftTitleLabel.bounds) + verticalOffset
	}];
	
	[_rightTitleLabel setCenter:(CGPoint){
		CGRectGetMidX(self.bounds) + _rightTitleOffset,
		CGRectGetMidY(_rightTitleLabel.bounds) + verticalOffset
	}];
	
	[_editButton setBounds:(CGRect){ CGPointZero, { _editTitleLabelWidth + 24, CGRectGetHeight(_editButton.titleLabel.bounds) + 8 }}];
	[_editButton setCenter:(CGPoint) { CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - (CGRectGetHeight(_editButton.bounds) / 2) }];
	
	[_cancelButton setBounds:(CGRect){ CGPointZero, { _cancelTitleLabelWidth + 24, CGRectGetHeight(_cancelButton.titleLabel.bounds) + 8 }}];
	[_cancelButton setCenter:(CGPoint) { CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - (CGRectGetHeight(_cancelButton.bounds) / 2) }];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view != _editButton && view != _cancelButton) {
		return nil;
	} else {
		return view;
	}
}

#pragma mark - Instance Methods

- (UIButton*)_newButton {
	LWFaceLibraryOverlayButton* button = [LWFaceLibraryOverlayButton buttonWithType:UIButtonTypeCustom];
	
	CGFloat mainScreenHeight = [[_device.nrDevice valueForProperty:@"mainScreenHeight"] floatValue];
	if (mainScreenHeight <= 340) {
		[button.titleLabel setFont:[UIFont systemFontOfSize:15]];
	} else if (mainScreenHeight <= 390 || mainScreenHeight <= 394) {
		[button.titleLabel setFont:[UIFont systemFontOfSize:16]];
	} else if (mainScreenHeight <= 448) {
		[button.titleLabel setFont:[UIFont systemFontOfSize:17]];
	}
	
	return button;
}

- (UILabel*)_newTitleLabel {
	UILabel* label = [UILabel new];
	
	CGFloat mainScreenHeight = [[_device.nrDevice valueForProperty:@"mainScreenHeight"] floatValue];
	if (mainScreenHeight <= 340) {
		[label setFont:[UIFont systemFontOfSize:12]];
	} else if (mainScreenHeight <= 390 || mainScreenHeight <= 394) {
		[label setFont:[UIFont systemFontOfSize:13]];
	} else if (mainScreenHeight <= 448) {
		[label setFont:[UIFont systemFontOfSize:14]];
	}
	
	[label setTextColor:[UIColor whiteColor]];
	
	return label;
}


- (void)setLeftTitle:(nullable NSString*)leftTitle {
	if (![_leftTitleLabel.text isEqualToString:leftTitle]) {
		[_leftTitleLabel setText:leftTitle];
		[_leftTitleLabel sizeToFit];
	}
}

- (void)setLeftTitleOffset:(CGFloat)leftTitleOffset alpha:(CGFloat)alpha {
	_leftTitleOffset = leftTitleOffset;
	_leftTitleAlpha = alpha;
	
	[_leftTitleLabel setAlpha:_leftTitleAlpha];
	[self setNeedsLayout];
}

- (void)setRightTitle:(nullable NSString*)rightTitle {
	if (![_rightTitleLabel.text isEqualToString:rightTitle]) {
		[_rightTitleLabel setText:rightTitle];
		[_rightTitleLabel sizeToFit];
	}
}

- (void)setRightTitleOffset:(CGFloat)rightTitleOffset alpha:(CGFloat)alpha {
	_rightTitleOffset = rightTitleOffset;
	_rightTitleAlpha = alpha;
	
	[_rightTitleLabel setAlpha:_rightTitleAlpha];
	[self setNeedsLayout];
}

@end