//
//  LWPageScrollView.m
//  LockWatch2
//
//  Created by janikschmidt on 1/15/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "LWPageView.h"
#import "LWPageScrollView.h"

#import "Core/LWEmulatedDevice.h"

@implementation LWPageScrollView 

- (id)initWithFrame:(CGRect)frame scrollOrientation:(NSInteger)orientation {
	if (self = [super initWithFrame:frame]) {
		_horizontal = (orientation == 0);
		
		[self setPagingEnabled:YES];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setClipsToBounds:NO];
		[self setDelegate:self];
		
		_fetchedPages = [NSMutableDictionary dictionary];
		
		_device = [CLKDevice currentDevice];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[self performSuppressingScrollCallbacks:^{
		[super setFrame:frame];
	}];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// if (!CGRectIsEmpty(self.bounds)) {
	// 	if (CGSizeEqualToSize(_boundsSizeOnLastLayout, CGSizeZero)) {
	// 		[self scrollToPageAtIndex:_currentPageIndex animated:NO];
	// 		[self tilePages];
	// 		[self performSuppressingScrollCallbacks:^{
	// 			[self updateContentSize];
	// 		}];
			
	// 		_boundsSizeOnLastLayout = self.bounds.size;
	// 	}
	// }
}

#pragma mark - Instance Methods

- (void)activate {
	if (!_activated) {
		_activated = YES;
		
		_numberOfPages = _numberOfPagesGetter();
		
		NSInteger pages = _numberOfPages - 1;
		for (int i = 0; i < pages; i++) {
			[self addSubview:[self fetchPageForIndex:i]];
		}
		
		if (!CGRectIsEmpty(self.bounds)) {
			[self updateContentSize];
			[self tilePages];
			[self scrollToPageAtIndex:_currentPageIndex animated:NO];
			[self setNeedsLayout];
			[self layoutIfNeeded];
		}
	}
}

- (CGPoint)centerForPageAtIndex:(NSInteger)index {
	if (_numberOfPages > index) {
		return (CGPoint){ (CGRectGetWidth(self.bounds) / 2) + (CGRectGetWidth(self.bounds) * index), CGRectGetHeight(self.bounds) / 2 };
	}
	
	return CGPointZero;
}

- (void)clearHandlers {
	_numberOfPagesGetter = nil;
	_pageGetter = nil;
}

- (CGPoint)contentOffsetToCenterPageAtIndex:(NSInteger)index {
	if (_numberOfPages > index) {
		CGPoint pageCenter = [self centerForPageAtIndex:index];
		return (CGPoint){ pageCenter.x - (CGRectGetWidth(self.bounds) / 2), 0 };
	}
	
	return CGPointZero;
}

- (NSInteger)currentPageIndex {
	return _currentPageIndex;
}

- (void)deactivate {
	if (_activated) {
		_activated = NO;
	}
}

- (void)enumeratePagesWithBlock:(void (^)(NSNumber* index, LWPageView* page, BOOL* stop))block {
	[_fetchedPages enumerateKeysAndObjectsUsingBlock:block];
}

- (LWPageView*)fetchPageForIndex:(NSInteger)index {
	LWPageView* pageView;
	pageView = [_fetchedPages objectForKey:@(index)];
	
	if (!pageView) {
		pageView = _pageGetter(index);
		[_fetchedPages setObject:pageView forKey:@(index)];
	}
	
	return pageView;
}

- (LWPageView*)pageAtIndex:(NSInteger)index {
	return [_fetchedPages objectForKey:@(index)];
}

- (void)performSuppressingScrollCallbacks:(void (^)())block {
	_suppressScrollCallbacks = YES;
	block();
	_suppressScrollCallbacks = NO;
}

- (void)reloadPages {
	if (_activated) {
		[self deactivate];
		[self activate];
	}
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
	if (_activated) {
		if (CGRectIsEmpty(self.bounds)) {
			if (_numberOfPages > index) {
				_currentPageIndex = index;
			}
		} else {
			[self setContentOffset:[self contentOffsetToCenterPageAtIndex:index] animated:animated];
		}
	}
}

- (void)setTilingSuspended:(BOOL)suspended {
	if (_tilingSuspended != suspended) {
		_tilingSuspended = suspended;
		
		if (!suspended) {
			[self tilePages];
		}
	}
}

- (void)tilePages {
	// if (_activated) {
	// 	if (!_tilingSuspended) {
	// 		[self enumeratePagesWithBlock:^(NSNumber* index, LWPageView* pageView, BOOL* stop) {
	// 			[pageView setFrame:(CGRect){{ CGRectGetWidth(_device.actualScreenBounds) * index.intValue, 0 }, { CGRectGetWidth(_device.actualScreenBounds), CGRectGetHeight(_device.actualScreenBounds) }}];
	// 		}];
	// 	}
	// }
}

- (void)updateContentSize {
	if (_horizontal) {
		[self setContentSize:(CGSize){ _numberOfPages * CGRectGetWidth(self.bounds), 0 }];
	} else {
		[self setContentSize:(CGSize){ 0, _numberOfPages * CGRectGetHeight(self.bounds) }];
	}
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if (!_suppressScrollCallbacks) {
		if (_numberOfPages != 0) {
			NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
			if (_currentPageIndex != pageIndex) {
				_currentPageIndex = pageIndex;
			}
			if (_didScrollHandler) {
				_didScrollHandler(scrollView);
			}
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	// if (!_suppressScrollCallbacks) {
	// 	if (_numberOfPages > 0) {
	// 		_currentPageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
	// 	}
	// }
}

@end