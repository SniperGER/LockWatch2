//
// LWClockFrameViewController.h
// LockWatch
//
// Created by janikschmidt on 9/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWClockFrameViewController : UIViewController {
	UIImageView* _bandImageView;
	UIImageView* _caseImageView;
}

@property (nonatomic, readonly) UIImage* bandImage;
@property (nonatomic, readonly) UIImage* caseImage;

- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated;
- (void)watchFrameChanged;

@end

NS_ASSUME_NONNULL_END