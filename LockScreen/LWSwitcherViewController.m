//
// LWSwitcherViewController.m
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWPageScrollView.h"
#import "LWPageView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedCLKDevice.h"

CGFloat SineEaseInOut(CGFloat p) {
	return 0.5 * (1 - cos(p * M_PI));
}

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
			[pageView setContentAlpha:0.35 * MIN(CLAMP(_zoomLevel, 0.5, 1), 1)];
			[pageView setOutlineAlpha:0.65 * MIN(CLAMP(_zoomLevel, 0.5, 1), 1)];
		} else {
			[pageView setContentAlpha:1.0];
			[pageView setOutlineAlpha:_zoomLevel];
		}
	}];
	
	[self.scrollView setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + (-7 * MIN(MAX(_zoomLevel, 0), 1)) }];
	
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
	CLKDevice* device = [CLKDevice currentDevice];
	
	if (_zoomLevel > 0) {
		CGFloat pageWidth = CGRectGetWidth(device.actualScreenBounds) - ((CGRectGetWidth(device.actualScreenBounds) - _pageWidthWhenZoomedOut) * _zoomLevel);
		
		CGRect pageBounds = (CGRect){
			CGPointZero,
			{
				pageWidth,
				(pageWidth / CGRectGetWidth(device.actualScreenBounds)) * CGRectGetHeight(device.actualScreenBounds)
			}
		};
		
		return (CGRect){
			{
				CGRectGetMidX(device.actualScreenBounds) - CGRectGetMidX(pageBounds),
				CGRectGetMidY(device.actualScreenBounds) - CGRectGetMidY(pageBounds) + (-7 * _zoomLevel),
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
	[self.scrollView scrollToPageAtIndex:index animated:NO];
	
	if (animated) {
		[self _setAnimatingZoom:YES];
	} else {
		[self setIncrementalZoomLevel:0];
		animations();
		block(YES);
		
		[self updatePageBehaviors];
		
		return;
	}
	
	CFTimeInterval startTime = CACurrentMediaTime();
	
	_zoomAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:60 / 1000 repeats:YES block:^(NSTimer* timer) {
		CGFloat progress = (CACurrentMediaTime() - startTime) / _zoomAnimationDuration;
		[self setIncrementalZoomLevel:MIN(MAX(1 - SineEaseInOut(progress), 0), 1)];
		
		animations();
		
		if (progress >= 1) {
			if (animated) {
				[self _setAnimatingZoom:NO];
			}
			
			block(YES);
			
			[self updatePageBehaviors];
			
			[timer invalidate];
			_zoomAnimationTimer = nil;
			
			return;
		}
	}];
}

@end