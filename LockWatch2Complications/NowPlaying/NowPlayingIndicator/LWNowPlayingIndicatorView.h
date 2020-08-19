//
// LWNowPlayingIndicatorView.h
// LockWatch
//
// Created by janikschmidt on 8/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LWNowPlayingIndicatorFullColorProvider, LWNowPlayingIndicatorProvider, MPUNowPlayingIndicatorView;

@interface LWNowPlayingIndicatorView : UIView {
	MPUNowPlayingIndicatorView* _indicatorView;
}

@property (nonatomic) UIColor* color;
@property (nonatomic) UIColor* overrideColor;
@property (nonatomic) LWNowPlayingIndicatorProvider* imageProvider;
@property (nonatomic) BOOL usesLegibility;

- (instancetype)initFullColorImageViewWithDevice:(CLKDevice*)device;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)layoutSubviews;
- (MPUNowPlayingIndicatorView*)_createIndicatorView;
- (void)configureWithImageProvider:(LWNowPlayingIndicatorFullColorProvider*)imageProvider reason:(int)reason;
- (UIColor*)overrideColor;
- (void)pauseLiveFullColorImageView;
- (void)resumeLiveFullColorImageView;

@end

NS_ASSUME_NONNULL_END