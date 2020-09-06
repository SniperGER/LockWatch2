//
// LWPageView.m
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "LWClockViewController.h"
#import "LWPageView.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWPageDelegate.h"

@implementation LWPageView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// _device = [CLKDevice currentDevice];
		
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setBounces:NO];
		[self setPagingEnabled:YES];
		[self setClipsToBounds:NO];
		[self setDelegate:self];
		[self setScrollEnabled:YES];
		
		_contentAlpha = 0.0;
		_outlineAlpha = 0.0;
		
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
		[self addGestureRecognizer:_tapGesture];
		
		[self setContentSize:(CGSize){ 0, CGRectGetHeight([[CLKDevice currentDevice] actualScreenBounds]) * 2 }];
		
		[self setScrollEnabled:_allowsDelete];
		[_tapGesture setEnabled:_allowsSelect];
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_legibilitySettingsChanged) name:@"ml.festival.lockwatch2/LegibilitySettingsChanged" object:nil];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CLKDevice* device = [CLKDevice currentDevice];
	
	[_contentView setBounds:(CGRect){ CGPointZero, _contentViewSize }];
	[_contentView setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - self.contentOffset.y }];
	
	CGFloat scale = _pageSize.width / CGRectGetWidth(device.actualScreenBounds);
	CGFloat contentViewScale = (CGRectGetWidth(device.actualScreenBounds) / CGRectGetWidth(device.screenBounds)) * scale;
	[_contentView setTransform:CGAffineTransformMakeScale(contentViewScale, contentViewScale)];
	
	if (_outlineView) {
		[_outlineView setFrame:UIEdgeInsetsInsetRect(_contentView.frame, _outlineInsets)];
		[_outlineView setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - self.contentOffset.y }];
		[_outlineView.layer setCornerRadius:_outlineCornerRadius * scale];
		
		if (_outlineView.superview != self) {
			[_outlineView removeFromSuperview];
			[self addSubview:_outlineView];
		}
		
		UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:_outlineView.bounds cornerRadius:_outlineView.layer.cornerRadius];
		[path setUsesEvenOddFillRule:YES];
		[path appendPath:[UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(_outlineView.bounds, (UIEdgeInsets){ 3, 3, 3, 3 }) cornerRadius:_outlineView.layer.cornerRadius - 3]];
		
		[_outlineViewMask setPath:path.CGPath];
		
		[self bringSubviewToFront:_contentView];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	return (CGSize){ _pageSize.width, CGRectGetHeight([[CLKDevice currentDevice] actualScreenBounds]) };
}

#pragma mark - Instance Methods

- (CGFloat)_deleteFractionForOffset:(CGPoint)offset {
	if (_allowsDelete) {
		return (offset.y / CGRectGetHeight(self.bounds));
	}
	
	return 0;
}

- (void)_handleTap:(UIGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self.pageDelegate pageWasSelected:self];
	}
}

- (void)_handleScrollingStopped {
	if ([self _deleteFractionForOffset:self.contentOffset] > 0.5) {
		[self.pageDelegate page:self didEndSwipeToDelete:YES];
	} else if (_swipingToDelete) {
		[self.pageDelegate page:self didEndSwipeToDelete:NO];
	}
	
	_swipingToDelete = NO;
}

- (void)_legibilitySettingsChanged {
	if (!_outlineView) return;
	
	_UILegibilitySettings* legibilitySettings = [LWClockViewController legibilitySettings];
	UIBlurEffect* effect;
	
	if (UIColorIsLightColor(legibilitySettings.primaryColor)) {
		effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	} else {
		effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	}
	
	[_outlineView setEffect:effect];
}

- (void)applyConfiguration {
	if (!_outlineView) {
		_outlineView = [[UIVisualEffectView alloc] initWithEffect:nil];
		[_outlineView setClipsToBounds:YES];
		[_outlineView setUserInteractionEnabled:NO];
		[self addSubview:_outlineView];
		
		_outlineViewMask = [CAShapeLayer layer];
		[_outlineViewMask setFillRule:kCAFillRuleEvenOdd];
		
		[_outlineView.layer setMask:_outlineViewMask];
	}
	
	[_outlineView.layer setCornerRadius:_outlineCornerRadius];
	
	if (@available(iOS 13.0, *)) {
		[_outlineView.layer setCornerCurve:kCACornerCurveContinuous];
	}

	[_outlineView setAlpha:_outlineAlpha];
	
	[self _legibilitySettingsChanged];
}

- (void)cancelDelete:(BOOL)animated {
	[self setContentOffset:CGPointZero animated:animated];
	
	if (!animated) {
		[self.pageDelegate page:self didEndSwipeToDelete:NO];
	}
}

- (void)prepareForReuse {
	[self setAlpha:1.0];
	[self setContentOffset:CGPointZero];
	
	[self setOutlineAlpha:1];
	[self setContentAlpha:1];
	[self setAllowsSelect:NO];
	
	[_contentView setTransform:CGAffineTransformIdentity];
	[self setContentView:nil];
	
	_outlineStrokeWidth = 1;
	_outlineCornerRadius = 0;
	_outlineInsets = UIEdgeInsetsZero;
}

- (void)setAllowsDelete:(BOOL)allowsDelete {
	_allowsDelete = allowsDelete;
	
	[self setScrollEnabled:allowsDelete];
}

- (void)setAllowsSelect:(BOOL)allowsSelect {
	_allowsSelect = allowsSelect;
	
	[_tapGesture setEnabled:allowsSelect];
}

- (void)setContentAlpha:(CGFloat)contentAlpha {
	_contentAlpha = contentAlpha;
	
	[_contentView setAlpha:contentAlpha];
}

- (void)setContentView:(nullable UIView*)contentView {
	if (_contentView != contentView) {
		[_contentView removeFromSuperview];
		[_contentView setTransform:CGAffineTransformIdentity];
		[_contentView setAlpha:1.0];
		
		_contentView = contentView;
		
		if (_contentView) {
			[self insertSubview:_contentView atIndex:0];
			[_contentView setAlpha:_contentAlpha];
		}
	}
}

- (void)setContentViewSize:(CGSize)contentViewSize {
	if (!CGSizeEqualToSize(_contentViewSize, contentViewSize)) {
		[self setNeedsLayout];
	}
	
	_contentViewSize = contentViewSize;
}

- (void)setOutlineAlpha:(CGFloat)outlineAlpha {
	_outlineAlpha = outlineAlpha;
	
	[_outlineView setAlpha:outlineAlpha];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	[self _handleScrollingStopped];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self _handleScrollingStopped];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView {
	[self _handleScrollingStopped];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if ([self _deleteFractionForOffset:self.contentOffset] < 0.15) {
		if (!_swipingToDelete) return;
		
		[self.pageDelegate page:self didUpdateSwipeToDelete:MIN(MAX(CLAMP([self _deleteFractionForOffset:self.contentOffset], 0.15, 1.0), 0), 1)];
	} else {
		if (!_swipingToDelete) {
			_swipingToDelete = YES;
			[self.pageDelegate pageDidBeginSwipeToDelete:self];
		}
		
		[self.pageDelegate page:self didUpdateSwipeToDelete:MIN(MAX(CLAMP([self _deleteFractionForOffset:self.contentOffset], 0.15, 1.0), 0), 1)];
	}
}

@end
