//
//  LWSwitcherViewController.m
//  LockWatch2
//
//  Created by janikschmidt on 1/14/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "LWPageView.h"
#import "LWPageScrollView.h"
#import "LWSwitcherViewController.h"

#import "Core/LWEmulatedDevice.h"
#import "Core/LWPageScrollViewControllerDataSource.h"

@interface LWSwitcherViewController () {
	CGFloat _previousScrollPosition;
}

@end

@implementation LWSwitcherViewController

- (id)init {
	return [self initWithScrollOrientation:0];
}

- (id)initWithScrollOrientation:(NSInteger)scrollOrientation {
	if (scrollOrientation != 0) {
		[NSException raise:NSInvalidArgumentException format:@"LWSwitcherViewController requires scroll orientation horizontal"];
	}
		
	if (self = [super initWithScrollOrientation:scrollOrientation]) {
		
	}
	
	return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
	
	CGFloat _pageWidth = CGRectGetWidth(_device.actualScreenBounds) - ((CGRectGetWidth(_device.actualScreenBounds) - _pageWidthWhenZoomedOut) * _zoomLevel);
	CGSize pageSize = (CGSize) {
		_pageWidth,
		CGRectGetHeight(_device.actualScreenBounds)
	};
	CGFloat scale = _pageWidth / CGRectGetWidth(_device.actualScreenBounds);

	[self.scrollView setFrame:(CGRect) {
		CGPointZero,
		{ pageSize.width + self.interpageSpacing, (_pageWidth / CGRectGetWidth(_device.actualScreenBounds)) * CGRectGetHeight(_device.actualScreenBounds) }
	}];
	[self.scrollView setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - (7 * _zoomLevel) }];
	
	[self.scrollView enumeratePagesWithBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
		[pageView setPageSize:pageSize];
		[pageView setOutlineAlpha:_zoomLevel];
		
		[pageView setFrame:(CGRect) {
			{ (self.interpageSpacing / 2) + ((pageView.pageSize.width + self.interpageSpacing) * index.intValue), 0 },
			pageView.pageSize
		}];
		[pageView setCenter:(CGPoint){ pageView.center.x, CGRectGetMidY(self.scrollView.bounds) }];
		
		[pageView.contentView setCenter:(CGPoint){ CGRectGetMidX(pageView.bounds), CGRectGetMidY(pageView.bounds) }];
		[pageView.contentView setTransform:CGAffineTransformMakeScale(scale, scale)];
		
		if (index.intValue != self.scrollView.currentPageIndex) {
			[pageView setAlpha:(0.35 * _zoomLevel)];
		} else {
			[pageView setAlpha:1.0];
		}
	}];
	
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
	
	[self.scrollView performSuppressingScrollCallbacks:^{
		[self.scrollView updateContentSize];
		[self.scrollView setContentOffset:[self.scrollView contentOffsetToCenterPageAtIndex:self.scrollView.currentPageIndex]];
	}];
}

#pragma mark - Instance Methods

- (void)beginIncrementalZoom {
	[self setAnimatingZoom:YES];
}

- (CGFloat)currentPageScale {
	return 1 - ((1 - _pageScaleWhenZoomedOut) * _zoomLevel);
}

- (void)setIncrementalZoomLevel:(CGFloat)zoomLevel {
	_zoomLevel = zoomLevel;
	
	[self.view setNeedsLayout];
	[self updateInterpageSpacing];
	[self.view layoutIfNeeded];
}

- (void)endIncrementalZoom {
	[self setIncrementalZoomLevel:MIN(MAX(roundf(_zoomLevel), 0), 1)];
	[self setAnimatingZoom:NO];
	// MIN(MAX(roundf(_zoomLevel), 0), 1)
}

- (void)handleScroll:(UIScrollView*)scrollView {
	if (_zoomLevel != 1) return;
	
	[super handleScroll:scrollView];
	
	NSInteger pageIndex = MAX(MIN(ceilf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds)), self.scrollView.numberOfPages - 1), 0);
	CGFloat width = CGRectGetWidth(scrollView.bounds);
	CGFloat pageProgress = ((pageIndex * width) - scrollView.contentOffset.x) / width;
	pageProgress = (round(pageProgress * 100)) / 100.0;
	
	NSInteger previousPageIndex = (pageIndex > 0) ? pageIndex : 0;
	NSInteger nextPageIndex = (pageIndex < self.scrollView.numberOfPages - 1) ? pageIndex : self.scrollView.numberOfPages - 1;
	
	if (_previousScrollPosition != scrollView.contentOffset.x) {
		[self.scrollView enumeratePagesWithBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
			[pageView setAlpha:0.35];
		}];
		
		if (_previousScrollPosition < scrollView.contentOffset.x) {
			// Scroll from right to left
			LWPageView* nextPage = [self.scrollView pageAtIndex:nextPageIndex];
			
			if (scrollView.contentOffset.x + width <= scrollView.contentSize.width && scrollView.contentOffset.x > 0) {
				NSInteger currentPageIndex = MAX(nextPageIndex - 1, 0);
				LWPageView* currentPage = [self.scrollView pageAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0.35, pageProgress)];
				[nextPage setAlpha:MAX(0.35, 1 - pageProgress)];
			} else if (scrollView.contentOffset.x <= 0) {
				LWPageView* currentPage = [self.scrollView pageAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (scrollView.contentOffset.x / width))];
			} else {
				LWPageView* currentPage = [self.scrollView pageAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 - ((scrollView.contentOffset.x + width) - scrollView.contentSize.width) / width)];
			}
		}
		
		if (_previousScrollPosition > scrollView.contentOffset.x) {
			// Scroll from left to right
			LWPageView* previousPage = [self.scrollView pageAtIndex:previousPageIndex];
			
			if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x + width <= scrollView.contentSize.width) {
				NSInteger currentPageIndex = MIN(previousPageIndex - 1, self.scrollView.numberOfPages);
				LWPageView* currentPage = [self.scrollView pageAtIndex:currentPageIndex];
				
				[currentPage setAlpha:MAX(0.35, pageProgress)];
				[previousPage setAlpha:MAX(0.35, 1 - pageProgress)];
			} else if (scrollView.contentOffset.x + width > scrollView.contentSize.width) {
				LWPageView* currentPage = [self.scrollView pageAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 - ((scrollView.contentOffset.x + width) - scrollView.contentSize.width) / width)];
			} else {
				LWPageView* currentPage = [self.scrollView pageAtIndex:pageIndex];
				[currentPage setAlpha:MAX(0.35, 1 + (scrollView.contentOffset.x / width))];
			}
		}
	}
	
	_previousScrollPosition = self.scrollView.contentOffset.x;
}

- (void)setAnimatingZoom:(BOOL)animatingZoom {
	_animatingZoom = animatingZoom;
	
	[self.scrollView setTilingSuspended:animatingZoom];
}

- (void)setDataSource:(id <LWPageScrollViewControllerDataSource>)dataSource {
	if (self.dataSource) {
		[self deactivate];
	}
	
	[super setDataSource:dataSource];
	
	if (self.dataSource) {
		[self activate];
	}
}

- (void)updateInterpageSpacing {
	[super setInterpageSpacing:(MIN(_zoomLevel, 1.0) * (_interpageSpacingWhenZoomedOut - _interpageSpacingWhenZoomedIn)) + _interpageSpacingWhenZoomedIn];
}

- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated withAnimations:(void (^)())animations completion:(void (^)(BOOL finished))completion {
	_zoomLevel = 0;
	
	[self.view setNeedsLayout];
	
	if (animated) {
		[self setAnimatingZoom:YES];
		
		[UIView animateWithDuration:_zoomAnimationDuration delay:0 options:0 animations:^{
			[self updateInterpageSpacing];
			[self scrollToPageAtIndex:index animated:NO];
			
			[self.view layoutIfNeeded];
			animations();
		} completion:^(BOOL finished) {
			[self setAnimatingZoom:NO];
			completion(finished);
		}];
	} else {
		animations();
		completion(YES);
	}
}

- (BOOL)zoomedOut {
	return _zoomLevel > 0;
}

@end
