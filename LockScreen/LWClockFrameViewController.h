//
// LWClockFrameViewController.h
// LockWatch
//
// Created by janikschmidt on 9/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWClockFrameViewController : UIViewController

@property (nonatomic) UIImageView* bandImageView;
@property (nonatomic) UIImageView* caseImageView;

- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated;
- (void)watchFrameChanged;

@end

NS_ASSUME_NONNULL_END