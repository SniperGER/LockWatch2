//
// LWSwitcherViewController.m
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define CLAMP(value, min, max) (value - min) / (max - min)

#import "LWPageScrollView.h"
#import "LWPageView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedCLKDevice.h"

@implementation LWSwitcherViewController

- (instancetype)init {
	return [self initWithScrollOrientation:0];
}

- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation {
	if (scrollOrientation != 0) {
		[NSException raise:NSInvalidArgumentException format:@"LWSwitcherViewController requires scroll orientation horizontal"];
	}
	
	self = [super initWithScrollOrientation:scrollOrientation];
	return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
	
	if ([self zoomedOut] && self.swipeToDeleteInProgress) return;
	
	[self.scrollView enumeratePagesWithBlock:^(LWPageView* pageView, NSInteger index, BOOL* stop) {
		if (index != self.scrollView.currentPageIndex) {
			[pageView setContentAlpha:MIN(_zoomLevel, 0.35)];
			[pageView setOutlineAlpha:MIN(_zoomLevel, 0.65)];
		} else {
			[pageView setContentAlpha:1.0];
			[pageView setOutlineAlpha:_zoomLevel];
		}
	}];
	
	[self.scrollView performSuppressingScrollCallbacks:^{
		[self.scrollView _updateContentSize];
		[self.scrollView setContentOffset:[self.scrollView _contentOffsetToCenterPageAtIndex:self.scrollView.currentPageIndex]];
	}];
}

#pragma mark - Instance Methods

- (BOOL)_canDeletePageAtIndex:(NSInteger)index {
	if (![self zoomedOut] || _animatingZoom) {
		return NO;
	} else {
		return [super _canDeletePageAtIndex:index];
	}
}

- (CGRect)_frameForCenteredPage {
	if (_zoomLevel > 0) {
		CGFloat pageWidth = CGRectGetWidth(_device.actualScreenBounds) - ((CGRectGetWidth(_device.actualScreenBounds) - _pageWidthWhenZoomedOut) * _zoomLevel);
		
		CGRect pageBounds = (CGRect){
			CGPointZero,
			{
				pageWidth,
				(pageWidth / CGRectGetWidth(_device.actualScreenBounds)) * CGRectGetHeight(_device.actualScreenBounds)
			}
		};
		
		return (CGRect){
			{
				CGRectGetMidX(_device.actualScreenBounds) - CGRectGetMidX(pageBounds),
				CGRectGetMidY(_device.actualScreenBounds) - CGRectGetMidY(pageBounds) + (-7 * _zoomLevel),
			},
			pageBounds.size
		};
	} else {
		return [super _frameForCenteredPage];
	}
}

- (void)_setAnimatingZoom:(BOOL)animatingZoom {
	_animatingZoom = animatingZoom;
	[self.scrollView setTilingSuspended:animatingZoom];
	[self updateScrollingEnabled];
}

- (BOOL)_shouldEnableScrolling {
	if (!self.zoomedOut || _animatingZoom) {
		return NO;
	} else {
		return [super _shouldEnableScrolling];
	}
}

- (void)_updateInterpageSpacing {
	[self setInterpageSpacing:(MIN(_zoomLevel, 1.0) * (_interpageSpacingWhenZoomedOut - _interpageSpacingWhenZoomedIn)) + _interpageSpacingWhenZoomedIn];
}


- (void)beginIncrementalZoom {
	[self _setAnimatingZoom:YES];
}

- (void)endIncrementalZoom {
	[self setIncrementalZoomLevel:MIN(MAX(floorf(_zoomLevel), 0), 1)];
	[self _setAnimatingZoom:NO];
	[self updatePageBehaviors];
}

- (void)setDataSource:(nullable id <LWPageScrollViewControllerDataSource>)dataSource {
	if (self.dataSource) {
		[self deactivate];
	}
	
	[super setDataSource:dataSource];
	
	if (self.dataSource) {
		[self activate];
	}
}

- (void)setIncrementalZoomLevel:(CGFloat)zoomLevel {
	_zoomLevel = zoomLevel;
	
	[self.view setNeedsLayout];
	[self _updateInterpageSpacing];
	[self.view layoutIfNeeded];
}

- (BOOL)zoomedOut {
	return _zoomLevel >= 1;
}

- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))block {
	[self zoomInPageAtIndex:index animated:animated withAnimations:nil completion:block];
}

- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated withAnimations:(void (^_Nullable)())animations completion:(void (^_Nullable)(BOOL finished))block {
	_zoomLevel = 0;
	
	[self.view setNeedsLayout];
	
	if (animated) {
		[self _setAnimatingZoom:YES];
	}
		
	[UIView animateWithDuration:(animated ? _zoomAnimationDuration : 0) delay:0 options:0 animations:^{
		[self _updateInterpageSpacing];
		[self scrollToPageAtIndex:index animated:NO];
		
		[self.view layoutIfNeeded];
		animations();
	} completion:^(BOOL finished) {
		if (animated) {
			[self _setAnimatingZoom:NO];
		}
		
		block(finished);
	}];
}

@end