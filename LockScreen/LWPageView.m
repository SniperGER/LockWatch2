//
//  LWPageView.m
//  LockWatch2
//
//  Created by janikschmidt on 1/15/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "Core/LWEmulatedDevice.h"

#import "Core/LWPageDelegate.h"

#import "LWPageView.h"

@implementation LWPageView 

- (id)init {
	if (self = [super init]) {
		_device = [CLKDevice currentDevice];
		
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setPagingEnabled:YES];
		[self setClipsToBounds:NO];
		[self setDelegate:self];
		[self setScrollEnabled:YES];
		
		_outlineInsets = (UIEdgeInsets){ -8, -8, -8, -8 };
		
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:_tapGesture];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat scale = (_pageSize.width / CGRectGetWidth(_device.actualScreenBounds));
	
	if (_outlineView) {
		[_outlineView setFrame:UIEdgeInsetsInsetRect((CGRect){ CGPointZero, _contentView.frame.size }, _outlineInsets)];
		[_outlineView setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) }];
		[_outlineView.layer setCornerRadius:(_device.screenCornerRadius * scale) + -_outlineInsets.top];
		[_outlineView setAlpha:_outlineAlpha];
	}
}

#pragma mark - Instance Methods

- (void)applyConfiguration {
	// self.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1];
	if (!_outlineView) {
		_outlineView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:9]];
		[_outlineView setUserInteractionEnabled:NO];
		[_outlineView setClipsToBounds:YES];
		[self insertSubview:_outlineView atIndex:0];
	}
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self.pageDelegate pageWasSelected:self];
	}
}

- (void)setContentView:(UIView*)contentView {
	if (_contentView != contentView) {
		[_contentView removeFromSuperview];
		[_contentView setTransform:CGAffineTransformIdentity];
		[_contentView setAlpha:1];
		
		_contentView = contentView;
		if (_contentView) {
			[self addSubview:_contentView];
			// [contentView setAlpha:_contentAlpha];
		}
	}
}

@end