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

@end