//
// LWDeleteConfirmationButton.m
// LockWatch2
//
// Created by janikschmidt on 2/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <SpringBoardUIServices/SBUILegibilityLabel.h>

#import "LWClockViewController.h"
#import "LWDeleteConfirmationButton.h"

extern NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);

@implementation LWDeleteConfirmationButton

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// _device = [CLKDevice currentDevice];
		
		UIImage* deleteConfirmationImage = [UIImage imageNamed:@"DeleteConfirmation" inBundle:[NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH] compatibleWithTraitCollection:nil];
		_deleteIconView = [[UIImageView alloc] initWithImage:[deleteConfirmationImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
		[_deleteIconView setTintColor:[UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:58.0/255.0 alpha:1]];
		[self addSubview:_deleteIconView];
		
		_deleteLabel = [SBUILegibilityLabel new];
		[_deleteLabel setString:NTKClockFaceLocalizedString(@"DELETE_CONFIRMATION", @"Delete")];
		[_deleteLabel setFont:[UIFont systemFontOfSize:14]];
		[_deleteLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
		[_deleteLabel sizeToFit];
		[self addSubview:_deleteLabel];
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_legibilitySettingsChanged) name:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	[_deleteIconView setCenter:(CGPoint) { CGRectGetMidX(self.bounds), CGRectGetMidY(_deleteIconView.bounds) }];
	[_deleteLabel setCenter:(CGPoint) { CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - CGRectGetMidY(_deleteLabel.bounds) }];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	
	[UIView animateWithDuration:0.2 animations:^{
		CGFloat scale = (highlighted ? 0.9 : 1.0);
		[self setTransform:CGAffineTransformMakeScale(scale, scale)];
	}];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return (CGSize){ CGRectGetWidth(_deleteLabel.bounds), CGRectGetHeight(_deleteIconView.bounds) + 7.5 + CGRectGetHeight(_deleteLabel.bounds) };
}

#pragma mark - Instance Methods

- (void)_legibilitySettingsChanged {
	[_deleteLabel setLegibilitySettings:[LWClockViewController legibilitySettings]];
}

@end