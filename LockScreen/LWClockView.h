//
// LWClockView.h
// LockWatch2
//
// Created by janikschmidt on 1/26/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LWClockViewDelegate;

@interface LWClockView : UIView

@property (nonatomic, weak) id <LWClockViewDelegate> delegate;

- (UIView*)hitTest:(CGPoint)point withEvent:(nullable UIEvent*)event;
- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END