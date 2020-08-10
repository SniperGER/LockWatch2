//
// LWNowPlayingIndicatorView.h
// LockWatch
//
// Created by janikschmidt on 8/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LWNowPlayingIndicatorImageProvider, MPUNowPlayingIndicatorView;

@interface LWNowPlayingIndicatorView : UIView {
	MPUNowPlayingIndicatorView* _indicatorView;
}

@property (nonatomic) UIColor* color;
@property (nonatomic) UIColor* overrideColor;
@property (nonatomic) LWNowPlayingIndicatorImageProvider* imageProvider;
@property (nonatomic) BOOL usesLegibility;

@end

NS_ASSUME_NONNULL_END