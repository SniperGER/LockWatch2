//
// LWFaceLibraryOverlayView.m
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <SpringBoardUIServices/SBUILegibilityLabel.h>

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWEmulatedNRDevice.h"

#import "LWClockViewController.h"
#import "LWFaceLibraryOverlayButton.h"
#import "LWFaceLibraryOverlayView.h"

extern NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);

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
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_legibilitySettingsChanged) name:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	NRDeviceMainScreenClass mainScreenClass = [[_device.nrDevice valueForProperty:@"mainScreenClass"] integerValue];
	CGFloat _labelCenterY = 0;
	
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			_labelCenterY = 8.75;
			break;
		case NRDeviceMainScreenClass40mm:
		case NRDeviceMainScreenClass42mm:
			_labelCenterY = 11.5;
			break;
		case NRDeviceMainScreenClass44mm:
			_labelCenterY = 14.5;
			break;
		default: break;
	}
	
	[_leftTitleLabel setCenter:(CGPoint){
		CGRectGetMidX(self.bounds) + _leftTitleOffset,
		_labelCenterY
	}];
	
	[_rightTitleLabel setCenter:(CGPoint){
		CGRectGetMidX(self.bounds) + _rightTitleOffset,
		_labelCenterY
	}];
	
	CGRect _buttonBounds = CGRectZero;
	CGPoint _buttonCenter = CGPointZero;
	
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			_buttonBounds = (CGRect){ CGPointZero, { 98, 25 }};
			_buttonCenter = (CGPoint){ CGRectGetMidX(_device.actualScreenBounds), CGRectGetHeight(_device.actualScreenBounds) - CGRectGetMidY(_buttonBounds) };
			break;
		case NRDeviceMainScreenClass40mm:
			_buttonBounds = (CGRect){ CGPointZero, { 113, 31 }};
			_buttonCenter = (CGPoint){ CGRectGetMidX(_device.actualScreenBounds), CGRectGetHeight(_device.actualScreenBounds) - (CGRectGetMidY(_buttonBounds) + 2) };
			break;
		case NRDeviceMainScreenClass42mm:
			_buttonBounds = (CGRect){ CGPointZero, { 102.5, 28 }};
			_buttonCenter = (CGPoint){ CGRectGetMidX(_device.actualScreenBounds), CGRectGetHeight(_device.actualScreenBounds) - CGRectGetMidY(_buttonBounds) };
			break;
		case NRDeviceMainScreenClass44mm:
			_buttonBounds = (CGRect){ CGPointZero, { 128, 31 }};
			_buttonCenter = (CGPoint){ CGRectGetMidX(_device.actualScreenBounds), CGRectGetHeight(_device.actualScreenBounds) - (CGRectGetMidY(_buttonBounds) + 2) };
			break;
		default: break;
	}
	
	[_editButton setBounds:_buttonBounds];
	[_editButton setCenter:_buttonCenter];
	
	[_cancelButton setBounds:_buttonBounds];
	[_cancelButton setCenter:_buttonCenter];
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

- (void)_legibilitySettingsChanged {
	[_leftTitleLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
	[_rightTitleLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
}

- (UIButton*)_newButton {
	LWFaceLibraryOverlayButton* button = [LWFaceLibraryOverlayButton buttonWithType:UIButtonTypeCustom];
	
	NRDeviceMainScreenClass mainScreenClass = [[_device.nrDevice valueForProperty:@"mainScreenClass"] integerValue];
	
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			[button.titleLabel setFont:[UIFont systemFontOfSize:15]];
			break;
		case NRDeviceMainScreenClass42mm:
			[button.titleLabel setFont:[UIFont systemFontOfSize:16]];
			break;
		case NRDeviceMainScreenClass40mm:
		case NRDeviceMainScreenClass44mm:
			[button.titleLabel setFont:[UIFont systemFontOfSize:17]];
			break;
		default: break;
	}
	
	return button;
}

- (SBUILegibilityLabel*)_newTitleLabel {
	SBUILegibilityLabel* label = [SBUILegibilityLabel new];
	
	NRDeviceMainScreenClass mainScreenClass = [[_device.nrDevice valueForProperty:@"mainScreenClass"] integerValue];
	
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			[label setFont:[UIFont systemFontOfSize:12]];
			break;
		case NRDeviceMainScreenClass40mm:
		case NRDeviceMainScreenClass42mm:
			[label setFont:[UIFont systemFontOfSize:13]];
			break;
		case NRDeviceMainScreenClass44mm:
			[label setFont:[UIFont systemFontOfSize:14]];
			break;
		default: break;
	}
	
	[label setLegibilitySettings:[LWClockViewController legibilitySettings]];
	
	return label;
}


- (void)setLeftTitle:(nullable NSString*)leftTitle {
	if (![_leftTitleLabel.string isEqualToString:leftTitle]) {
		[_leftTitleLabel setString:leftTitle];
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
	if (![_rightTitleLabel.string isEqualToString:rightTitle]) {
		[_rightTitleLabel setString:rightTitle];
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