//
// LWFaceLibraryOverlayButton.m
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>

#import "LWClockViewController.h"
#import "LWFaceLibraryOverlayButton.h"

@implementation LWFaceLibraryOverlayButton

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setTitle:@"" forState:UIControlStateNormal];
		
		_visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
		[_visualEffectView setUserInteractionEnabled:NO];
		[_visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_visualEffectView setClipsToBounds:YES];
		
		if (@available(iOS 13, *)) {
			[_visualEffectView.layer setCornerCurve:kCACornerCurveContinuous];
		}
		
		[self insertSubview:_visualEffectView atIndex:0];
		
		[NSLayoutConstraint activateConstraints:@[
			[_visualEffectView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[_visualEffectView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
			[_visualEffectView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
			[_visualEffectView.heightAnchor constraintEqualToAnchor:self.heightAnchor]
		]];
		
		[self _legibilitySettingsChanged];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_legibilitySettingsChanged) name:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self sendSubviewToBack:_visualEffectView];
	[_visualEffectView.layer setCornerRadius:[[CLKDevice currentDevice] isLuxo] ? CGRectGetHeight(self.bounds) / 2 : 8];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
	
	[UIView animateWithDuration:highlighted ? 0.0 : 0.2 animations:^{
		[self setAlpha:highlighted ? 0.4 : 1.0];
	}];
}

#pragma mark - Instance Methods

- (void)_legibilitySettingsChanged {
	_UILegibilitySettings* legibilitySettings = [LWClockViewController legibilitySettings];
	UIBlurEffect* effect;
	
	if (UIColorIsLightColor(legibilitySettings.primaryColor)) {
		effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	} else {
		effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	}
	
	[_visualEffectView setEffect:effect];
}

@end