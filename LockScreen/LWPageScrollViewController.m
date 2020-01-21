//
//  LWPageScrollViewController.m
//  LockWatch2
//
//  Created by janikschmidt on 1/14/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "LWPageView.h"
#import "LWPageScrollView.h"
#import "LWPageScrollViewController.h"

#import "Core/LWEmulatedDevice.h"
#import "Core/LWPageScrollViewControllerDataSource.h"
#import "Core/LWPageScrollViewControllerDelegate.h"

@interface LWPageScrollViewController ()

@end

@implementation LWPageScrollViewController

- (id)initWithScrollOrientation:(NSInteger)scrollOrientation {
	if (self = [super init]) {
		_device = [CLKDevice currentDevice];
		_pageViewControllers = [NSMutableDictionary dictionary];
		_recycledPages = [NSMutableSet set];
		
		_scrollEnabled = YES;
		_scrollOrientation = scrollOrientation;
		
		/// TODO: Page Scroll View
		_scrollView = [[LWPageScrollView alloc] initWithFrame:CGRectZero scrollOrientation:scrollOrientation];
	}
	
	return self;
}

- (void)loadView {
	UIScrollView* view = [[UIScrollView alloc] initWithFrame:CGRectZero];
	[view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view setBounces:NO];
	[view setClipsToBounds:NO];
	
	[view addSubview:_scrollView];
	
	self.view = view;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	CGRect frameForCenteredPage = [self frameForCenteredPage];
	if (_scrollOrientation != 0) {
		frameForCenteredPage = CGRectInset(frameForCenteredPage, 0, _interpageSpacing / 2);
	} else {
		frameForCenteredPage = CGRectInset(frameForCenteredPage, _interpageSpacing / 2, 0);
	}
	
	[_scrollView setFrame:frameForCenteredPage];
	[_scrollView enumeratePagesWithBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
		[pageView setPageSize:_device.actualScreenBounds.size];
	}];
	
	[_scrollView setNeedsLayout];
	[_scrollView layoutIfNeeded];
	
	[_scrollView setVisualInsets:(UIEdgeInsets){ 0, 10, 0, 10 }];
}

#pragma mark - Instance Methods

- (void)activate {
	[_scrollView activate];
}

- (CGSize)contentViewSizeForPageAtIndex:(NSInteger)index {
	return [self.delegate pageScrollViewController:self contentViewSizeForPageAtIndex:index];
}

- (NSInteger)currentPageIndex {
	return _scrollView.currentPageIndex;
}

- (void)deactivate {
	[_scrollView deactivate];
}

- (void)ensureViewControllerForPageAtIndex:(NSInteger)index {
	UIViewController* controller = [self viewControllerForPageAtIndex:index];
	
	if (!controller) {
		controller = [self.dataSource pageScrollViewController:self viewControllerForPageAtIndex:index];
		
		if (controller) {
			[_pageViewControllers setObject:controller forKey:@(index)];
		}
	}
}

- (CGRect)frameForCenteredPage {
	if (self.view) {
		return _device.actualScreenBounds;
	} else {
		return CGRectZero;
	}
}

- (void)handleScroll:(UIScrollView*)scrollView {
	if (self.delegate) {
		[self.delegate pageScrollViewControllerDidScroll:self];
	}
}

- (NSInteger)indexOfPage:(LWPageView*)pageView {
	NSInteger __block index = -1;
	
	[_scrollView enumeratePagesWithBlock:^(NSNumber* _index, LWPageView* page, BOOL* stop) {
		if (page == pageView) {
			index = [_index integerValue];
			*stop = YES;
			return;
		}
	}];
	
	return index;
}

- (LWPageView*)pageForIndex:(NSInteger)index {
	[self ensureViewControllerForPageAtIndex:index];
	
	LWPageView* pageView;
	
	if ([_recycledPages anyObject]) {
		pageView = [_recycledPages anyObject];
	} else {
		pageView = [LWPageView new];
	}
	
	[_recycledPages removeObject:pageView];
	[pageView setPageDelegate:self];
	
	UIViewController* controller = [self viewControllerForPageAtIndex:index];
	[pageView setContentView:controller.view];
	
	[pageView setContentViewSize:[self contentViewSizeForPageAtIndex:index]];
	[pageView setPageSize:[self frameForCenteredPage].size];
	
	[pageView applyConfiguration];
	
	return pageView;
}

- (NTKFaceViewController*)pageViewControllerAtIndex:(NSInteger)index {
	return [_pageViewControllers objectForKey:@(index)];
}

- (void)reloadPages {
	[_scrollView reloadPages];
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
	[_scrollView scrollToPageAtIndex:index animated:animated];
}

- (void)setDataSource:(id <LWPageScrollViewControllerDataSource>)dataSource {
	_dataSource = dataSource;
	
	[self updateScrollViewHandlers];
}

- (void)setInterpaceSpacing:(CGFloat)interpageSpacing {
	_interpageSpacing = interpageSpacing;
	
	if (interpageSpacing != 0) {
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	}
}

- (void)updateScrollViewHandlers {
	[_scrollView clearHandlers];
	
	if (self.dataSource) {
		__weak LWPageScrollViewController* blockSelf = self;
		[_scrollView setNumberOfPagesGetter:^NSInteger () {
			return [blockSelf.dataSource pageScrollViewControllerNumberOfPages:blockSelf];
		}];
		
		[_scrollView setPageGetter:^LWPageView* (NSInteger index) {
			return [blockSelf pageForIndex:index];
		}];
		
		[_scrollView setDidScrollHandler:^(UIScrollView* scrollView) {
			[blockSelf handleScroll:scrollView];
		}];
	}
}

- (UIViewController*)viewControllerForPageAtIndex:(NSInteger)index {
	return [_pageViewControllers objectForKey:@(index)];
}

#pragma mark - LWPageDelegate

- (void)pageWasSelected:(LWPageView*)page {
	NSInteger index = [self indexOfPage:page];
	
	[self.delegate pageScrollViewController:self didSelectPageAtIndex:index];
}

@end
