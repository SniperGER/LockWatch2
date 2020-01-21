//
//  LWPageScrollView.h
//  LockWatch2
//
//  Created by janikschmidt on 1/15/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLKDevice, LWPageView;

@interface LWPageScrollView : UIScrollView <UIScrollViewDelegate> {
	BOOL _horizontal;
    BOOL _activated;
	NSMutableDictionary *_fetchedPages;
	CLKDevice *_device;
	BOOL _tilingSuspended;
	BOOL _suppressScrollCallbacks;
	CGSize _boundsSizeOnLastLayout;
	NSInteger _currentPageIndex;
}

@property (nonatomic, copy) NSInteger (^numberOfPagesGetter)();
@property (nonatomic, copy) LWPageView* (^pageGetter)(NSInteger index);
@property (nonatomic, copy) void (^didScrollHandler)(UIScrollView* scrollView);
@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic) UIEdgeInsets visualInsets;

- (id)initWithFrame:(CGRect)frame scrollOrientation:(NSInteger)orientation;
- (void)activate;
- (CGPoint)centerForPageAtIndex:(NSInteger)index;
- (void)clearHandlers;
- (CGPoint)contentOffsetToCenterPageAtIndex:(NSInteger)index;
- (NSInteger)currentPageIndex;
- (void)deactivate;
- (void)enumeratePagesWithBlock:(void (^)(NSNumber* index, LWPageView* page, BOOL* stop))block;
- (LWPageView*)fetchPageForIndex:(NSInteger)index;
- (LWPageView*)pageAtIndex:(NSInteger)index;
- (void)performSuppressingScrollCallbacks:(void (^)())block;
- (void)reloadPages;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setTilingSuspended:(BOOL)suspended;
- (void)tilePages;
- (void)updateContentSize;

@end