//
// LWPageScrollView.h
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Private)
- (BOOL)_isAnimatingScroll;
@end

@class CLKDevice, LWPageView;

@interface LWPageScrollView : UIScrollView <UIScrollViewDelegate> {
	BOOL _horizontal;
    BOOL _activated;
    NSMutableDictionary* _tiledPages;
    NSMutableDictionary* _fetchedPages;
	CGSize _boundsSizeOnLastLayout;
	BOOL _animatingScroll;
	BOOL _suppressScrollCallbacks;
	BOOL _scrollingStarted;
	CGPoint _swipeStartOffset;
    BOOL _swipeStartOffsetHasBeenSet;
	CLKDevice* _device;
}

@property (copy, nonatomic) NSInteger (^numberOfPagesGetter)();
@property (copy, nonatomic) LWPageView* (^pageGetter)(NSInteger index);
@property (copy, nonatomic) void (^willAddPageToViewHandler)(NSInteger index);
@property (copy, nonatomic) void (^didAddPageToViewHandler)(NSInteger index);
@property (copy, nonatomic) void (^willRemovePageFromViewHandler)(NSInteger index);
@property (copy, nonatomic) void (^didRemovePageFromViewHandler)(NSInteger index);
@property (copy, nonatomic) void (^pagePurgeHandler)(LWPageView* pageView, NSInteger index);
@property (copy, nonatomic) void (^didPurgePagesHandler)();
@property (copy, nonatomic) void (^didScrollToIndexHandler)(NSInteger index);
@property (copy, nonatomic) void (^willDecelerateToIndexHandler)();
@property (copy, nonatomic) void (^didScrollHandler)();
@property (copy, nonatomic) void (^didStopScrollingHandler)();
@property (copy, nonatomic) void (^didStartScrollingHandler)();
@property (copy, nonatomic) void (^pageDeletionHandler)(NSInteger index);
@property (copy, nonatomic) void (^pageScrollToDeleteHandler)(NSInteger pageIndex, NSInteger deleteIndex);
@property (copy, nonatomic) NSInteger (^pageDeletionScrollDirectionHandler)(NSInteger deleteIndex);
@property (copy, nonatomic) void (^willAnimatePageDeletionHandler)(NSInteger index, NSInteger destinationIndex);
@property (copy, nonatomic) void (^isAnimatingPageDeletionHandler)();
@property (copy, nonatomic) void (^didAnimatePageDeletionHandler)();

@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic) BOOL tilingSuspended;
@property (nonatomic) UIEdgeInsets visualInsets;

- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation;
- (void)layoutSubviews;
- (void)setFrame:(CGRect)frame;
- (void)__rebuildPageIndices;
- (CGPoint)_centerForPageAtIndex:(NSInteger)index;
- (CGPoint)_contentOffsetToCenterPageAtIndex:(NSInteger)index;
- (LWPageView*)_fetchPageForIndex:(NSInteger)index;
- (void)_layoutPage:(LWPageView*)pageView atIndex:(NSInteger)index;
- (void)_layoutPages;
- (NSInteger)_pageIndexAtPoint:(CGPoint)point;
- (void)_purgePageAtIndex:(NSInteger)index;
- (void)_scrollViewDidStart;
- (void)_scrollViewDidStop;
- (void)_tilePageForIndex:(NSInteger)index;
- (void)_tilePagesEagerly:(BOOL)eagerly;
- (NSInteger)_unclippedPageIndexAtPoint:(CGPoint)point;
- (void)_untilePageAtIndex:(NSInteger)index;
- (void)_updateContentSize;
- (CGRect)_visualInsetBounds;
- (void)activate;
- (void)clearHandlers;
- (void)deactivate;
- (void)deletePageAtIndex:(NSInteger)index animated:(BOOL)animated updateModel:(BOOL)updateModel;
- (void)enumeratePagesWithBlock:(void (^)(LWPageView* pageView, NSInteger index, BOOL* stop))block;
- (void)getCurrentScrollFraction:(CGFloat*)fraction lowPageIndex:(NSInteger*)lowPageIndex highPageIndex:(NSInteger*)highPageIndex;
- (void)insertPageAtIndex:(NSInteger)index;
- (LWPageView*)pageAtIndex:(NSInteger)index;
- (void)performSuppressingScrollCallbacks:(void (^)())block;
- (void)purgePages;
- (void)reloadPages;
- (void)setTilingSuspended:(BOOL)tilingSuspended;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END