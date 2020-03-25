//
// LWClockViewDelegate.h
// LockWatch2
//
// Created by janikschmidt on 2/11/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@protocol LWClockViewDelegate <NSObject>

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event;

@end