//
// LWClockView.m
// LockWatch2
//
// Created by janikschmidt on 1/26/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWClockView.h"

#import "Core/LWClockViewDelegate.h"

@implementation LWClockView

- (UIView*)hitTest:(CGPoint)point withEvent:(nullable UIEvent*)event {
	UIView* view = [self.delegate hitTest:point withEvent:event];

	return view;
}

- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated {
	if (!animated) {
		[super setAlpha:alpha];
		return;
	}
	
	[UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.1 options:0 animations:^{
		[super setAlpha:alpha];
	} completion:nil];
}

@end