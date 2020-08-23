//
// LWPageScrollView.m
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>

#import "LWPageScrollView.h"
#import "LWPageView.h"

@implementation LWPageScrollView

- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation {
	if (self = [super initWithFrame:CGRectZero]) {
		_horizontal = (scrollOrientation == 0);
		
		[self setPagingEnabled:YES];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setClipsToBounds:NO];
		[self setDelegate:self];
		
		_tiledPages = [NSMutableDictionary dictionary];
		_fetchedPages = [NSMutableDictionary dictionary];
		
		// _device = [CLKDevice currentDevice];
	}
	
	return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view) return view;
	
	for (UIView* subview in [self.subviews reverseObjectEnumerator]) {
		CGPoint convertedPoint = [subview convertPoint:point fromView:self];
		UIView* hitView = [subview hitTest:convertedPoint withEvent:event];
		if (hitView) {
			return hitView;
		}
	}
	
	return nil;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (!CGRectIsEmpty(self.bounds)) {
		if (CGSizeEqualToSize(self.bounds.size, _boundsSizeOnLastLayout)) {
			// [self _tilePagesEagerly:NO];
		} else {
			[self scrollToPageAtIndex:_currentPageIndex animated:NO];
			
			[self performSuppressingScrollCallbacks:^{
				[self _updateContentSize];
			}];
			
			[self _tilePagesEagerly:YES];
			[self _layoutPages];
			
			_boundsSizeOnLastLayout = self.bounds.size;
		}
	}
}

- (void)setFrame:(CGRect)frame {
	[self performSuppressingScrollCallbacks:^{
		[super setFrame:frame];
	}];
}

#pragma mark - Instance Methods

- (void)__rebuildPageIndices {
	NSDictionary* fetchedPagesCopy = [_fetchedPages copy];
	[_fetchedPages removeAllObjects];
	
	[[fetchedPagesCopy.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber* number1, NSNumber* number2) {
        return [number1 compare:number2];
    }] enumerateObjectsUsingBlock:^(NSNumber* indexKey, NSUInteger index, BOOL* stop) {
		[_fetchedPages setObject:[fetchedPagesCopy objectForKey:indexKey] forKey:@(index)];
	}];
	
	
	NSDictionary* tiledPagesCopy = [_tiledPages copy];
	[_tiledPages removeAllObjects];
	
	[[tiledPagesCopy.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber* number1, NSNumber* number2) {
        return [number1 compare:number2];
    }] enumerateObjectsUsingBlock:^(NSNumber* indexKey, NSUInteger index, BOOL* stop) {
		[_tiledPages setObject:[tiledPagesCopy objectForKey:indexKey] forKey:@(index)];
	}];
}

- (CGPoint)_centerForPageAtIndex:(NSInteger)index {
	if (_numberOfPages > index) {
		return (CGPoint){
			(CGRectGetWidth(self.bounds) / 2) + (CGRectGetWidth(self.bounds) * index),
			CGRectGetMidY(self.bounds)
		};
	}
	
	return CGPointZero;
}

- (CGPoint)_contentOffsetToCenterPageAtIndex:(NSInteger)index {
	if (_numberOfPages > index) {
		CGPoint pageCenter = [self _centerForPageAtIndex:index];
		return (CGPoint){
			pageCenter.x - (CGRectGetWidth(self.bounds) / 2),
			0
		};
	}
	
	return CGPointZero;
}

- (LWPageView*)_fetchPageForIndex:(NSInteger)index {
	LWPageView* pageView = [_fetchedPages objectForKey:@(index)];
	
	if (!pageView) {
		if (_pageGetter) {
			pageView = _pageGetter(index);
			[_fetchedPages setObject:pageView forKey:@(index)];
		}
	}
	
	return pageView;
}

- (void)_layoutPage:(LWPageView*)pageView atIndex:(NSInteger)index {
	[pageView sizeToFit];
	[pageView setCenter:[self _centerForPageAtIndex:index]];
}

- (void)_layoutPages {
	[_tiledPages enumerateKeysAndObjectsUsingBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
		[self _layoutPage:pageView atIndex:index.integerValue];
	}];
}

- (NSInteger)_pageIndexAtPoint:(CGPoint)point {
	if (_numberOfPages > 0) {
		NSInteger _index = [self _unclippedPageIndexAtPoint:point];
		
		NSInteger index = 0;
		if (_index >= 0) {
			index = _index;
		}
		if (_numberOfPages - 1 <= index) {
			index = _numberOfPages - 1;
		}
		
		return index;
	}
	
	return 0;
}

- (void)_purgePageAtIndex:(NSInteger)index {
	LWPageView* pageView = [_fetchedPages objectForKey:@(index)];
	
	if (pageView) {
		[pageView removeFromSuperview];
		[_fetchedPages removeObjectForKey:@(index)];
		
		if (_pagePurgeHandler) {
			_pagePurgeHandler(pageView, index);
		}
	}
}

- (void)_scrollViewDidStart {
	if (!_scrollingStarted) {
		_scrollingStarted = YES;
		
		if (_didStartScrollingHandler) {
			_didStartScrollingHandler();
		}
	}
}

- (void)_scrollViewDidStop {
	if (_scrollingStarted) {
		_scrollingStarted = NO;
		
		if (_didStopScrollingHandler) {
			_didStopScrollingHandler();
		}
		
		[self _tilePagesEagerly:YES];
	}
}

- (void)_tilePageForIndex:(NSInteger)index {
	LWPageView* pageView = [self _fetchPageForIndex:index];
	
	if (pageView) {
		if (_willAddPageToViewHandler) {
			_willAddPageToViewHandler(index);
		}
		
		if (!pageView.superview) {
			[self addSubview:pageView];
		}
		
		[pageView setHidden:NO];
		[_tiledPages setObject:pageView forKey:@(index)];
		
		if (_didAddPageToViewHandler) {
			_didAddPageToViewHandler(index);
		}
		
		[UIView performWithoutAnimation:^{
			[self _layoutPage:pageView atIndex:index];
		}];
	}
}

- (void)_tilePagesEagerly:(BOOL)eagerly {
	if (_activated && !_tilingSuspended) {
		if (_numberOfPages > 0) {
			for (int i = 0; i < _numberOfPages; i++) {
				[self _tilePageForIndex:i];
			}
			
			if (eagerly) {
				// _purgePageAtIndex
				// _fetchPageForIndex
			}
		}
	}
}

- (NSInteger)_unclippedPageIndexAtPoint:(CGPoint)point {
	if (_horizontal) {
		return floor(point.x / CGRectGetWidth(self.bounds));
	} else {
		return floor(point.y / CGRectGetHeight(self.bounds));
	}
}

- (void)_untilePageAtIndex:(NSInteger)index {
	LWPageView* pageView = [_tiledPages objectForKey:@(index)];
	
	if (pageView) {
		if (_willRemovePageFromViewHandler) {
			_willRemovePageFromViewHandler(index);
		}
		
		[pageView setHidden:YES];
		[pageView removeFromSuperview];
		[_tiledPages removeObjectForKey:@(index)];
		
		if (_didRemovePageFromViewHandler) {
			_didRemovePageFromViewHandler(index);
		}
	}
}

- (void)_updateContentSize {
	if (_horizontal) {
		[self setContentSize:(CGSize){ _numberOfPages * CGRectGetWidth(self.bounds), 0 }];
	} else {
		[self setContentSize:(CGSize){ 0, _numberOfPages * CGRectGetHeight(self.bounds) }];
	}
}

- (CGRect)_visualInsetBounds {
	return UIEdgeInsetsInsetRect(self.bounds, _visualInsets);
}


- (void)activate {
	if (!_activated) {
		_activated = YES;
		_numberOfPages = _numberOfPagesGetter();
		
		[self _updateContentSize];
		[self _tilePagesEagerly:YES];
		[self scrollToPageAtIndex:_currentPageIndex animated:NO];
		
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
}

- (void)clearHandlers {
	_pageDeletionScrollDirectionHandler = nil;
	_pageScrollToDeleteHandler = nil;
	_pageDeletionHandler = nil;
	_didStartScrollingHandler = nil;
	_didStopScrollingHandler = nil;
	_didScrollHandler = nil;
	_willDecelerateToIndexHandler = nil;
	_didScrollToIndexHandler = nil;
	_didRemovePageFromViewHandler = nil;
	_willRemovePageFromViewHandler = nil;
	_didAddPageToViewHandler = nil;
	_willAddPageToViewHandler = nil;
	_pageGetter = nil;
	_numberOfPagesGetter = nil;
}

- (void)deactivate {
	if (_activated) {
		[self purgePages];
		
		_activated = NO;
	}
}

- (void)deletePageAtIndex:(NSInteger)index animated:(BOOL)animated updateModel:(BOOL)updateModel {
	if (_numberOfPages <= index) return;
	
	NSInteger pageDeletionScrollDirection = _pageDeletionScrollDirectionHandler(index);
	NSInteger destinationDirection = (pageDeletionScrollDirection == 0 ? 1 : -1);
	
	if (animated) {
		if (_willAnimatePageDeletionHandler) {
			_willAnimatePageDeletionHandler(index, index + destinationDirection);
		}
	}
	
	[self _untilePageAtIndex:index];
	[self _purgePageAtIndex:index];
	[self __rebuildPageIndices];
	
	if (_didPurgePagesHandler) {
		_didPurgePagesHandler();
	}
	
	if (_numberOfPages > 0) {
		_currentPageIndex = _currentPageIndex - pageDeletionScrollDirection;
		_numberOfPages -= 1;
	}
	
	if (updateModel) {
		if (pageDeletionScrollDirection != 0) {
			if (_pageScrollToDeleteHandler) {
				_pageScrollToDeleteHandler(_currentPageIndex, index);
			} else if (_pageDeletionHandler) {
				_pageDeletionHandler(index);
			}
		} else if (_pageDeletionHandler) {
			_pageDeletionHandler(index);
		}
	} else {
		[self _tilePagesEagerly:YES];
	}
	
	[UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{	
		[self _layoutPages];
		[self performSuppressingScrollCallbacks:^{
			[self scrollToPageAtIndex:_currentPageIndex animated:NO];
		}];
		
		if (animated && _isAnimatingPageDeletionHandler) {
			_isAnimatingPageDeletionHandler();
		}
	} completion:^(BOOL finished){
		[self _scrollViewDidStop];
		[self _updateContentSize];
		
		if (animated && _didAnimatePageDeletionHandler) {
			_didAnimatePageDeletionHandler();
		}
	}];
}

- (void)enumeratePagesWithBlock:(void (^)(LWPageView* pageView, NSInteger index, BOOL* stop))block {
	[_fetchedPages enumerateKeysAndObjectsUsingBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
		block(pageView, index.integerValue, stop);
	}];
}

- (void)getCurrentScrollFraction:(CGFloat*)fraction lowPageIndex:(NSInteger*)lowPageIndex highPageIndex:(NSInteger*)highPageIndex {
	*lowPageIndex = floorf(self.contentOffset.x / CGRectGetWidth(self.bounds));
	*highPageIndex = ceilf(self.contentOffset.x / CGRectGetWidth(self.bounds));
	
	CGFloat width = CGRectGetWidth(self.bounds);
	CGFloat pageProgress = ((*lowPageIndex * width) - self.contentOffset.x) / width;
	pageProgress = (round(pageProgress * 100)) / 100.0;
	*fraction = -pageProgress;
}

- (void)insertPageAtIndex:(NSInteger)index {
	[self _tilePagesEagerly:YES];
	_numberOfPages += 1;
	
	if (_currentPageIndex >= index) {
		_currentPageIndex = index + 1;
	}
	
	[self _tilePageForIndex:index];
	[self _layoutPages];
	[self _updateContentSize];
}

- (LWPageView*)pageAtIndex:(NSInteger)index {
	return [_tiledPages objectForKey:@(index)];
}

- (void)performSuppressingScrollCallbacks:(void (^)())block {
	_suppressScrollCallbacks = YES;
	block();
	_suppressScrollCallbacks = NO;
}

- (void)purgePages {
	[self enumeratePagesWithBlock:^(LWPageView* pageView, NSInteger index, BOOL* stop) {
		[self _purgePageAtIndex:index];
	}];
	
	if (_didPurgePagesHandler) {
		_didPurgePagesHandler();
	}
}

- (void)reloadPages {
	if (_activated) {
		[self deactivate];
		[self activate];
	}
}

- (void)setTilingSuspended:(BOOL)tilingSuspended {
	if (tilingSuspended != _tilingSuspended) {
		_tilingSuspended = tilingSuspended;
		
		if (!tilingSuspended) {
			[self _tilePagesEagerly:YES];
		}
	}
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
	if (_activated) {
		if (CGRectIsEmpty(self.bounds)) {
			if (_numberOfPages > index) {
				_currentPageIndex = index;
			}
		} else {
			_currentPageIndex = index;
			[self setContentOffset:[self _contentOffsetToCenterPageAtIndex:index] animated:animated];
		}
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self _scrollViewDidStop];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self _scrollViewDidStop];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView {
	_animatingScroll = NO;
	[self _scrollViewDidStop];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if (!_suppressScrollCallbacks) {
		if (_numberOfPages != 0) {
			if ([self _isAnimatingScroll] && !_animatingScroll) {
				_animatingScroll = YES;
				[self _scrollViewDidStart];
			}
			
			NSInteger calculatedPageIndex = [self _pageIndexAtPoint:scrollView.contentOffset];
			if (calculatedPageIndex >= _numberOfPages) {
				calculatedPageIndex = 0;
			}
			
			if (calculatedPageIndex != _currentPageIndex) {
				_currentPageIndex = calculatedPageIndex;
				
				if (_didScrollToIndexHandler) {
					_didScrollToIndexHandler(_currentPageIndex);
				}
			}
			
			if (_didScrollHandler) {
				_didScrollHandler();
			}
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
	[self _scrollViewDidStart];
}

@end