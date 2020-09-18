//
// LWPageScrollViewController.m
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NTKFaceViewController.h>

#import "LWPageScrollView.h"
#import "LWPageScrollViewController.h"
#import "LWPageView.h"

#import "Core/LWEmulatedCLKDevice.h"
#import "Core/LWEmulatedNRDevice.h"
#import "Core/LWPageScrollViewControllerDataSource.h"
#import "Core/LWPageScrollViewControllerDelegate.h"

@implementation LWPageScrollViewController

- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation {
	if (self = [super init]) {
		// _device = [CLKDevice currentDevice];
		
		_pageViewControllers = [NSMutableDictionary dictionary];
		_recycledPages = [NSMutableSet set];
		
		_scrollEnabled = YES;
		_scrollOrientation = scrollOrientation;
		
		_scrollView = [[LWPageScrollView alloc] initWithScrollOrientation:scrollOrientation];
	}
	
	return self;
}

- (void)loadView {
	UIScrollView* view = [[UIScrollView alloc] initWithFrame:[[CLKDevice currentDevice] actualScreenBounds]];
	[view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view setBounces:NO];
	[view setClipsToBounds:NO];
	self.view = view;
	
	[self.view addSubview:_scrollView];
}

- (void)viewDidLayoutSubviews {
	if (!CGRectIsEmpty(self.view.bounds)) {
		CGRect frameForCenteredPage = [self _frameForCenteredPage];
		if (_scrollOrientation == 1) {
			frameForCenteredPage = CGRectInset(frameForCenteredPage, 0, _interpageSpacing / -2);
		} else {
			frameForCenteredPage = CGRectInset(frameForCenteredPage, _interpageSpacing / -2, 0);
		}
		
		if (!CGRectEqualToRect(_scrollView.frame, frameForCenteredPage)) {
			[_scrollView performSuppressingScrollCallbacks:^{
				[_scrollView setFrame:frameForCenteredPage];
				[_scrollView setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) }];
				[_scrollView setVisualInsets:(UIEdgeInsets){ 0, 10, 0, 10 }];
			}];
			
			[_scrollView enumeratePagesWithBlock:^(LWPageView* pageView, NSInteger index, BOOL* stop) {
				[pageView setPageSize:[self _frameForCenteredPage].size];
				[pageView setContentViewSize:[self _contentViewSizeForPageAtIndex:index]];
			}];
			
			if (_deleteConfirmationView) {
				[_deleteConfirmationView sizeToFit];
				
				if ([[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenClass"] integerValue] == NRDeviceMainScreenClass44mm) {
					[_deleteConfirmationView setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 7 }];
				} else {
					[_deleteConfirmationView setCenter:(CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) }];
				}
			}
		}
	}
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

#pragma mark - Instance Methods

- (void)__rebuildPageViewControllerIndices {
	NSMutableDictionary* pageViewControllersCopy = [_pageViewControllers copy];
	[_pageViewControllers removeAllObjects];
	
	NSArray* sortedKeys = [pageViewControllersCopy.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber* number1, NSNumber* number2) {
        return [number1 compare:number2];
    }];
	
	[sortedKeys enumerateObjectsUsingBlock:^(NSNumber* indexKey, NSUInteger index, BOOL* stop) {
		[_pageViewControllers setObject:[pageViewControllersCopy objectForKey:indexKey] forKey:@(index)];
	}];
}

- (void)_applyDefaultConfigurationToPage:(LWPageView*)pageView {
	return;
}

- (BOOL)_canDeletePageAtIndex:(NSInteger)index {
	return [self.delegate pageScrollViewController:self canDeletePageAtIndex:index];
}

- (BOOL)_canSelectPageAtIndex:(NSInteger)index {
	return [self.delegate pageScrollViewController:self canSelectPageAtIndex:index];
}

- (void)_configureBehaviorsForPage:(LWPageView*)pageView atIndex:(NSInteger)index {
	[pageView setAllowsSelect:[self _canSelectPageAtIndex:index]];
	[pageView setAllowsDelete:[self _canDeletePageAtIndex:index]];
}

- (CGSize)_contentViewSizeForPageAtIndex:(NSInteger)index {
	return [self.delegate pageScrollViewController:self contentViewSizeForPageAtIndex:index];
}

- (CGRect)_frameForCenteredPage {
	return [[CLKDevice currentDevice] actualScreenBounds];
}

- (void)_handleDidAnimatePageDeletion {
	[self.delegate pageScrollViewControllerDidAnimatePageDeletion:self];
	[self _tearDownPageDeletion];
}

- (void)_handleIsAnimatingPageDeletion {
	[self.delegate pageScrollViewControllerIsAnimatingPageDeletion:self];
	[_deleteConfirmationView setAlpha:0];
}

- (void)_handlePageDeletion:(NSInteger)index {
	[self.delegate pageScrollViewController:self didDeletePageAtIndex:index];
	[self updatePageBehaviors];
}

- (void)_handleScroll {
	[self.delegate pageScrollViewControllerDidScroll:self];
	
	if ([self.delegate respondsToSelector:@selector(pageScrollViewController:didScrollToOffset:)]) {
		[self.delegate pageScrollViewController:self didScrollToOffset:_scrollView.contentOffset];
	}
}

- (void)_handleScrollingDidStart {
	[self.delegate pageScrollViewControllerDidStartScrolling:self];
}

- (void)_handleScrollingDidStop {
	[self.delegate pageScrollViewControllerDidStopScrolling:self];
	[self updatePageBehaviors];
}

- (void)_handleScrollingToPage:(NSInteger)index toDeletePageAtIndex:(NSInteger)deleteIndex {
	[self.delegate pageScrollViewController:self didScrollToPageAtIndex:index toDeleteIndex:deleteIndex];
	[self updatePageBehaviors];
}

- (void)_handleWillAnimatePageDeletion:(NSInteger)index destinationIndex:(NSInteger)destinationIndex {
	[self.delegate pageScrollViewController:self willAnimatePageDeletion:index destinationIndex:destinationIndex];
}

- (NSInteger)_indexOfPage:(LWPageView*)pageView {
	NSInteger __block index = -1;
	
	[_scrollView enumeratePagesWithBlock:^(LWPageView* page, NSInteger _index, BOOL* stop) {
		if (page == pageView) {
			index = _index;
			*stop = YES;
			return;
		}
	}];
	
	return index;
}

- (LWPageView*)_pageForIndex:(NSInteger)index {
	[self ensureViewControllerForPageAtIndex:index];
	
	LWPageView* pageView = [_recycledPages anyObject];
	if (!pageView) {
		pageView = [[LWPageView alloc] init];
	} 
	
	[_recycledPages removeObject:pageView];
	[pageView setPageDelegate:self];
	
	UIViewController* viewController = [self _viewControllerForPageAtIndex:index];
	[pageView setContentView:viewController.view];
	
	[pageView setContentViewSize:[self _contentViewSizeForPageAtIndex:index]];
	[pageView setPageSize:[self _frameForCenteredPage].size];
	
	[self _configureBehaviorsForPage:pageView atIndex:index];
	[self _applyDefaultConfigurationToPage:pageView];
	
	[self.delegate pageScrollViewController:self configurePage:pageView atIndex:index];
	[pageView applyConfiguration];
	
	return pageView;
}

- (void)_purgeViewControllerForPageAtIndex:(NSInteger)index {
	[_pageViewControllers removeObjectForKey:@(index)];
}

- (void)_recyclePage:(LWPageView*)pageView {
	[pageView prepareForReuse];
}

- (BOOL)_shouldEnableScrolling {
	return _scrollEnabled;
}

- (void)_tearDownPageDeletion {
	_swipeToDeleteInProgress = NO;
    [_scrollView setUserInteractionEnabled:YES];
    [_deleteConfirmationView setHidden:YES];
}

- (void)_updateScrollViewHandlers {
	[_scrollView clearHandlers];
	
	if (_dataSource) {
		__weak LWPageScrollViewController* _weak_self = self;
		
		[_scrollView setNumberOfPagesGetter:^NSInteger {
			return [_weak_self.dataSource pageScrollViewControllerNumberOfPages:_weak_self];
		}];
		
		[_scrollView setPageGetter:^id (NSInteger index) {
			return [_weak_self _pageForIndex:index];
		}];
		
		[_scrollView setWillAddPageToViewHandler:^(NSInteger index) {
			if ([_weak_self _viewControllerForPageAtIndex:index]) {
				[_weak_self addChildViewController:[_weak_self _viewControllerForPageAtIndex:index]];
			}
		}];
		
		[_scrollView setDidAddPageToViewHandler:^(NSInteger index) {
			[[_weak_self _viewControllerForPageAtIndex:index] didMoveToParentViewController:_weak_self];
		}];
		
		[_scrollView setWillRemovePageFromViewHandler:^(NSInteger index) {
			[[_weak_self _viewControllerForPageAtIndex:index] willMoveToParentViewController:nil];
		}];
		
		[_scrollView setDidRemovePageFromViewHandler:^(NSInteger index) {
			[[_weak_self _viewControllerForPageAtIndex:index] removeFromParentViewController];
		}];
		
		[_scrollView setPagePurgeHandler:^(LWPageView* pageView, NSInteger index) {
			[_weak_self _recyclePage:pageView];
			[_weak_self _purgeViewControllerForPageAtIndex:index];
		}];
		
		[_scrollView setDidPurgePagesHandler:^{
			[_weak_self __rebuildPageViewControllerIndices];
		}];
		
		[_scrollView setDidScrollToIndexHandler:^(NSInteger index) {
			[_weak_self ensureViewControllerForPageAtIndex:index];
			
			if ([_weak_self.delegate respondsToSelector:@selector(pageScrollVIewController:didScrollToPageAtIndex:)]) {
				[_weak_self.delegate pageScrollViewController:_weak_self didScrollToPageAtIndex:index];
			}
		}];
		
		[_scrollView setDidScrollHandler:^{
			[_weak_self _handleScroll];
		}];
		
		[_scrollView setDidStartScrollingHandler:^{
			[_weak_self _handleScrollingDidStart];
		}];
		
		[_scrollView setDidStopScrollingHandler:^{
			[_weak_self _handleScrollingDidStop];
		}];
		
		[_scrollView setPageDeletionHandler:^(NSInteger index) {
			[_weak_self _handlePageDeletion:index];
		}];
		
		[_scrollView setPageScrollToDeleteHandler:^(NSInteger pageIndex, NSInteger deleteIndex) {
			[_weak_self _handleScrollingToPage:pageIndex toDeletePageAtIndex:deleteIndex];
		}];
		
		[_scrollView setPageDeletionScrollDirectionHandler:^NSInteger (NSInteger deleteIndex) {
			return [_weak_self.delegate pageScrollViewController:_weak_self scrollDirectionForDeletedIndex:deleteIndex];
		}];
		
		[_scrollView setWillAnimatePageDeletionHandler:^(NSInteger index, NSInteger destinationIndex) {
			[_weak_self _handleWillAnimatePageDeletion:index destinationIndex:destinationIndex];
		}];
		
		[_scrollView setIsAnimatingPageDeletionHandler:^(NSInteger index, NSInteger destinationIndex) {
			[_weak_self _handleIsAnimatingPageDeletion];
		}];
		
		[_scrollView setDidAnimatePageDeletionHandler:^{
			[_weak_self _handleDidAnimatePageDeletion];
		}];
	}
}

- (UIViewController*)_viewControllerForPageAtIndex:(NSInteger)index {
	return [_pageViewControllers objectForKey:@(index)];
}


- (void)activate {
	[_scrollView activate];
}

- (void)deactivate {
	[_scrollView deactivate];
}

- (void)cancelPageDeletion {
	[self cancelPageDeletionAnimated:YES];
}

- (void)cancelPageDeletionAnimated:(BOOL)animated {
	if (_swipeToDeleteInProgress) {
		[[_scrollView pageAtIndex:_swipeToDeleteIndex] cancelDelete:animated];
	}
}

- (void)confirmPageDeletion {
	if (_swipeToDeleteInProgress) {
		[_scrollView deletePageAtIndex:_swipeToDeleteIndex animated:YES updateModel:YES];
	}
}

- (NSInteger)currentPageIndex {
	return _scrollView.currentPageIndex;
}

- (void)ensureViewControllerForPageAtIndex:(NSInteger)index {
	UIViewController* controller = [self _viewControllerForPageAtIndex:index];
	
	if (!controller) {
		controller = [self.dataSource pageScrollViewController:self viewControllerForPageAtIndex:index];
		
		if (controller) {
			[_pageViewControllers setObject:controller forKey:@(index)];
		}
	}
}

- (NTKFaceViewController*)pageViewControllerAtIndex:(NSInteger)index {
	return [_pageViewControllers objectForKey:@(index)];
}

- (void)reloadPages {
	[_scrollView reloadPages];
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
	[_scrollView scrollToPageAtIndex:index animated:animated];
}

- (void)setDataSource:(nullable id <LWPageScrollViewControllerDataSource>)dataSource {
	if (_dataSource != dataSource) {
		_dataSource = dataSource;
		[self _updateScrollViewHandlers];
	}
}

- (void)setDelegate:(nullable id <LWPageScrollViewControllerDelegate>)delegate {
	if (_delegate != delegate) {
		_delegate = delegate;
		
		// I could update the delegate flags, but who cares at this point anyways?
		
		[self _updateScrollViewHandlers];
	}
}

- (void)setDeleteConfirmationView:(UIView*)deleteConfirmationView {
	if (_deleteConfirmationView != deleteConfirmationView) {
		[_deleteConfirmationView removeFromSuperview];
		
		_deleteConfirmationView = deleteConfirmationView;
		if (_deleteConfirmationView) {
			[self.view insertSubview:_deleteConfirmationView atIndex:0];
			[_deleteConfirmationView setHidden:!_swipeToDeleteInProgress];
		}
	}
}

- (void)setScrollEnabled:(BOOL)enabled {
	_scrollEnabled = enabled;
	[self updateScrollingEnabled];
}

- (void)updatePageBehaviors {
	[_scrollView enumeratePagesWithBlock:^(LWPageView* pageView, NSInteger index, BOOL* stop) {
		[self _configureBehaviorsForPage:pageView atIndex:index];
	}];
}

- (void)updateScrollingEnabled {
	[_scrollView setScrollEnabled:[self _shouldEnableScrolling]];
}

#pragma mark - LWPageDelegate

- (void)page:(LWPageView*)pageView didEndSwipeToDelete:(BOOL)completed {
	if (_swipeToDeleteInProgress) {
		[self.delegate pageScrollViewController:self didEndSwipeToDeleteAtIndex:_swipeToDeleteIndex deleted:completed];
		
		[self setScrollEnabled:YES];
		
		if (completed) {
			if (_deleteConfirmationView) {
				[_scrollView setUserInteractionEnabled:NO];
			} else {
				[_scrollView deletePageAtIndex:_swipeToDeleteIndex animated:YES updateModel:YES];
			}
		} else {
			[self _tearDownPageDeletion];
		}
	}
}

- (void)page:(LWPageView*)pageView didUpdateSwipeToDelete:(CGFloat)fraction {
	if (_swipeToDeleteInProgress) {
		[self.delegate pageScrollViewController:self didUpdateSwipeToDeleteAtIndex:_swipeToDeleteIndex fraction:fraction];
		
		[pageView setAlpha:1 - CLAMP(fraction, 0.5, 1.0)];
		[_deleteConfirmationView setAlpha:fraction];
	}
}

- (void)pageDidBeginSwipeToDelete:(LWPageView*)pageView {
	NSInteger pageIndex = [self _indexOfPage:pageView];
	
	if (pageIndex != -1) {
		_swipeToDeleteInProgress = YES;
		_swipeToDeleteIndex = pageIndex;
		
		[_deleteConfirmationView setHidden:NO];
		[self setScrollEnabled:NO];
		
		[self.delegate pageScrollViewController:self didBeginSwipeToDeleteAtIndex:pageIndex];
	}
}

- (void)pageWasSelected:(LWPageView*)pageView {
	NSInteger pageIndex = [self _indexOfPage:pageView];
	
	if (pageIndex != -1) {
		[self.delegate pageScrollViewController:self didSelectPageAtIndex:pageIndex];
	}
}

@end