//
// LWNowPlayingIndicatorView.m
// LockWatch
//
// Created by janikschmidt on 8/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>
#import <MPUFoundation/MPUNowPlayingIndicatorView.h>

#import "LWNowPlayingIndicatorFullColorProvider.h"
#import "LWNowPlayingIndicatorProvider.h"
#import "LWNowPlayingIndicatorView.h"

@implementation LWNowPlayingIndicatorView

- (instancetype)initFullColorImageViewWithDevice:(CLKDevice*)device {
	return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_indicatorView = [self _createIndicatorView];
		[_indicatorView setPlaybackState:2];
		[self addSubview:_indicatorView];
		
		[self setFrame:_indicatorView.bounds];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[_indicatorView setPlaybackState:_imageProvider.paused ? 2 : 1];
	[_indicatorView _reloadLevelViews];
}

#pragma mark - Instance Methods

- (MPUNowPlayingIndicatorView*)_createIndicatorView {
	MPUNowPlayingIndicatorView* indicatorView = [[MPUNowPlayingIndicatorView alloc] initWithFrame:CGRectZero];
	[indicatorView setInterLevelSpacing:1.5];
	[indicatorView setLevelCornerRadius:0];
	[indicatorView setLevelWidth:2];
	[indicatorView setMaximumLevelHeight:12.5];
	[indicatorView setNumberOfLevels:4];
	[indicatorView sizeToFit];
	
	return indicatorView;
}

- (void)configureWithImageProvider:(LWNowPlayingIndicatorFullColorProvider*)imageProvider reason:(int)reason {
	[_indicatorView setPlaybackState:imageProvider.paused ? 2 : 1];
	[_indicatorView setTintColor:imageProvider.tintColor];
	[_indicatorView _reloadLevelViews];
}

- (UIColor*)overrideColor {
	if (_overrideColor) return _overrideColor;
	
	return _color;
}

- (void)pauseLiveFullColorImageView {
	return;
}

- (void)resumeLiveFullColorImageView {
	return;
}

- (void)setColor:(UIColor*)color {
	_color = color;
	
	[_indicatorView setTintColor:color];
	[_indicatorView _reloadLevelViews];
}

- (void)setImageProvider:(LWNowPlayingIndicatorProvider*)imageProvider {
	if (![imageProvider isKindOfClass:NSClassFromString(@"LWNowPlayingIndicatorProvider")]) return;
	_imageProvider = imageProvider;
	
	if ([NSThread isMainThread]) {
		[self setNeedsLayout];
		[self layoutIfNeeded];
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setNeedsLayout];
			[self layoutIfNeeded];
		});
	}
}

@end