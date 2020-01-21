//
//  LWPageScrollViewController.h
//  LockWatch2
//
//  Created by janikschmidt on 1/14/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core/LWPageDelegate.h"

@protocol LWPageScrollViewControllerDataSource, LWPageScrollViewControllerDelegate;
@class CLKDevice, LWPageScrollView, LWPageView, NTKFaceViewController;

@interface LWPageScrollViewController : UIViewController <LWPageDelegate> {
	CLKDevice* _device;
	NSMutableDictionary* _pageViewControllers;
	NSMutableSet* _recycledPages;
	BOOL _scrollEnabled;
	NSInteger _scrollOrientation;
}

@property (retain, nonatomic) UIView* deleteConfirmationView;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) CGFloat interpageSpacing;
@property (nonatomic, readonly) LWPageScrollView* scrollView;
@property (nonatomic) id <LWPageScrollViewControllerDataSource> dataSource;
@property (nonatomic) id <LWPageScrollViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSInteger currentPageIndex;

- (id)initWithScrollOrientation:(NSInteger)scrollOrientation;
- (void)activate;
- (CGSize)contentViewSizeForPageAtIndex:(NSInteger)index;
- (NSInteger)currentPageIndex;
- (void)deactivate;
- (void)ensureViewControllerForPageAtIndex:(NSInteger)index;
- (CGRect)frameForCenteredPage;
- (void)handleScroll:(UIScrollView*)scrollView;
- (NSInteger)indexOfPage:(LWPageView*)pageView;
- (LWPageView*)pageForIndex:(NSInteger)index;
- (NTKFaceViewController*)pageViewControllerAtIndex:(NSInteger)index;
- (void)reloadPages;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setDataSource:(id <LWPageScrollViewControllerDataSource>)dataSource;
- (void)setInterpaceSpacing:(CGFloat)interpageSpacing;
- (void)updateScrollViewHandlers;
- (UIViewController*)viewControllerForPageAtIndex:(NSInteger)index;

@end