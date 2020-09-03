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
		
		// _device = device;
		NRDeviceMainScreenClass mainScreenClass = [[device.nrDevice valueForProperty:@"mainScreenClass"] integerValue];
		
		_leftTitleLabel = [self _newTitleLabel];
		[self addSubview:_leftTitleLabel];
		
		_rightTitleLabel = [self _newTitleLabel];
		[self addSubview:_rightTitleLabel];
		
		_shareButton = [self _newShareButton];
		[self addSubview:_shareButton];
		
		_editButton = [self _newEditOrCancelButton];
		[_editButton setTitle:NTKClockFaceLocalizedString(@"EDIT_FACE", @"Customize") forState:UIControlStateNormal];
		[self addSubview:_editButton];
		
		_cancelButton = [self _newEditOrCancelButton];
		[_cancelButton setTitle:NTKClockFaceLocalizedString(@"CANCEL_ADD_FACE", @"Cancel") forState:UIControlStateNormal];
		[_cancelButton setHidden:YES];
		[self addSubview:_cancelButton];
		
		
		
		[NSLayoutConstraint activateConstraints:@[
			[_shareButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:0],
			[_shareButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2],
			
			[_editButton.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:0],
			[_editButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2],
			
			[_cancelButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:0],
			[_cancelButton.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:0],
			[_cancelButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2],
			[_cancelButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
		]];
		
		switch (mainScreenClass) {
			case NRDeviceMainScreenClass38mm:
				[NSLayoutConstraint activateConstraints:@[
					[_shareButton.widthAnchor constraintEqualToConstant:26],
					[_shareButton.heightAnchor constraintEqualToConstant:26],
					
					[_editButton.widthAnchor constraintGreaterThanOrEqualToConstant:64],
					[_editButton.heightAnchor constraintEqualToConstant:26],
					[_editButton.leadingAnchor constraintEqualToAnchor:_shareButton.trailingAnchor constant:6],
					[_editButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:16],
					
					[_cancelButton.widthAnchor constraintGreaterThanOrEqualToConstant:74],
					[_cancelButton.heightAnchor constraintEqualToConstant:26]
				]];
				break;
			case NRDeviceMainScreenClass42mm:
				[NSLayoutConstraint activateConstraints:@[
					[_shareButton.widthAnchor constraintEqualToConstant:28],
					[_shareButton.heightAnchor constraintEqualToConstant:28],
					
					[_editButton.widthAnchor constraintGreaterThanOrEqualToConstant:72.5],
					[_editButton.heightAnchor constraintEqualToConstant:28],
					[_editButton.leadingAnchor constraintEqualToAnchor:_shareButton.trailingAnchor constant:6],
					[_editButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:17],
					
					[_cancelButton.widthAnchor constraintGreaterThanOrEqualToConstant:78.5],
					[_cancelButton.heightAnchor constraintEqualToConstant:28]
				]];
				break;
			case NRDeviceMainScreenClass40mm:
				[NSLayoutConstraint activateConstraints:@[
					[_shareButton.widthAnchor constraintEqualToConstant:31],
					[_shareButton.heightAnchor constraintEqualToConstant:31],
					
					[_editButton.widthAnchor constraintGreaterThanOrEqualToConstant:87],
					[_editButton.heightAnchor constraintEqualToConstant:31],
					[_editButton.leadingAnchor constraintEqualToAnchor:_shareButton.trailingAnchor constant:4],
					[_editButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:17.5],
					
					[_cancelButton.widthAnchor constraintGreaterThanOrEqualToConstant:113],
					[_cancelButton.heightAnchor constraintEqualToConstant:31]
				]];
				break;
			case NRDeviceMainScreenClass44mm:
				[NSLayoutConstraint activateConstraints:@[
					[_shareButton.widthAnchor constraintEqualToConstant:31],
					[_shareButton.heightAnchor constraintEqualToConstant:31],
					
					[_editButton.widthAnchor constraintGreaterThanOrEqualToConstant:87.5],
					[_editButton.heightAnchor constraintEqualToConstant:31],
					[_editButton.leadingAnchor constraintEqualToAnchor:_shareButton.trailingAnchor constant:5],
					[_editButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:18],
					
					[_cancelButton.widthAnchor constraintGreaterThanOrEqualToConstant:128],
					[_cancelButton.heightAnchor constraintEqualToConstant:31]
				]];
				break;
			default: break;
		}
		
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_legibilitySettingsChanged) name:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CLKDevice* device = [CLKDevice currentDevice];
	
	NRDeviceMainScreenClass mainScreenClass = [[device.nrDevice valueForProperty:@"mainScreenClass"] integerValue];
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
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view == _shareButton || view == _editButton || view == _cancelButton) {
		return view;
	}
	
	return nil;
}

#pragma mark - Instance Methods

- (CGFloat)_buttonFontSizeForScreenClass:(NRDeviceMainScreenClass)mainScreenClass {
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			return 15;
		case NRDeviceMainScreenClass42mm:
			return 16;
		case NRDeviceMainScreenClass40mm:
		case NRDeviceMainScreenClass44mm:
			return 17;
		default: break;
	}
	
	return 0;
}

- (CGFloat)_labelFontSizeForScreenClass:(NRDeviceMainScreenClass)mainScreenClass {
	switch (mainScreenClass) {
		case NRDeviceMainScreenClass38mm:
			return 12;
		case NRDeviceMainScreenClass40mm:
		case NRDeviceMainScreenClass42mm:
			return 13;
		case NRDeviceMainScreenClass44mm:
			return 14;
		default: break;
	}
	
	return 0;
}

- (void)_legibilitySettingsChanged {
	[_leftTitleLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
	[_rightTitleLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
}

- (UIButton*)_newEditOrCancelButton {
	NRDeviceMainScreenClass mainScreenClass = [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenClass"] integerValue];
	LWFaceLibraryOverlayButton* button = [LWFaceLibraryOverlayButton buttonWithType:UIButtonTypeCustom];
	
	[button setContentEdgeInsets:[[CLKDevice currentDevice] isLuxo] ? (UIEdgeInsets){ 0, 10, 0, 10 } : (UIEdgeInsets){ 0, 12, 0, 12 }];
	[button.titleLabel setFont:[UIFont systemFontOfSize:[self _buttonFontSizeForScreenClass:mainScreenClass]]];
	[button.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	
	return button;
}

- (UIButton*)_newShareButton {
	LWFaceLibraryOverlayButton* button = [LWFaceLibraryOverlayButton buttonWithType:UIButtonTypeCustom];
	
	[button setAdjustsImageWhenDisabled:NO];
	[button setTintColor:UIColor.whiteColor];
	
	NRDeviceMainScreenClass mainScreenClass = [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenClass"] integerValue];
	[button setImage:[UIImage systemImageNamed:@"square.and.arrow.up" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:[self _labelFontSizeForScreenClass:mainScreenClass]]] forState:UIControlStateNormal];
	
	return button;
}

- (SBUILegibilityLabel*)_newTitleLabel {
	SBUILegibilityLabel* label = [SBUILegibilityLabel new];
	
	NRDeviceMainScreenClass mainScreenClass = [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenClass"] integerValue];
	[label setFont:[UIFont systemFontOfSize:[self _labelFontSizeForScreenClass:mainScreenClass]]];
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