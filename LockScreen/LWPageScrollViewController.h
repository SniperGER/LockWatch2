//
// LWPageScrollViewController.h
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

#import "Core/LWPageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LWPageScrollViewControllerDataSource, LWPageScrollViewControllerDelegate;
@class CLKDevice, LWPageScrollView, LWPageView, NTKFaceViewController;

@interface LWPageScrollViewController : UIViewController <LWPageDelegate> {
	CLKDevice* _device;
	NSInteger _scrollOrientation;
	NSMutableDictionary* _pageViewControllers;
	NSMutableSet* _recycledPages;
}

@property (nonatomic, retain) UIView* deleteConfirmationView;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) double interpageSpacing;
@property (nonatomic, readonly) LWPageScrollView* scrollView;
@property (nonatomic, weak) id <LWPageScrollViewControllerDelegate> _Nullable delegate;
@property (nonatomic, weak) id <LWPageScrollViewControllerDataSource> _Nullable dataSource;
@property (nonatomic, readonly) BOOL swipeToDeleteInProgress;
@property (nonatomic, readonly) NSInteger swipeToDeleteIndex;
@property (nonatomic, readonly) NSInteger currentPageIndex;

- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation;
- (void)loadView;
- (void)viewDidLayoutSubviews;
- (BOOL)_canShowWhileLocked;
- (void)__rebuildPageViewControllerIndices;
- (void)_applyDefaultConfigurationToPage:(LWPageView*)pageView;
- (BOOL)_canDeletePageAtIndex:(NSInteger)index;
- (BOOL)_canSelectPageAtIndex:(NSInteger)index;
- (void)_configureBehaviorsForPage:(LWPageView*)pageView atIndex:(NSInteger)index;
- (CGSize)_contentViewSizeForPageAtIndex:(NSInteger)index;
- (CGRect)_frameForCenteredPage;
- (void)_handleDidAnimatePageDeletion;
- (void)_handleIsAnimatingPageDeletion;
- (void)_handlePageDeletion:(NSInteger)index;
- (void)_handleScroll;
- (void)_handleScrollingDidStart;
- (void)_handleScrollingDidStop;
- (void)_handleScrollingToPage:(NSInteger)index toDeletePageAtIndex:(NSInteger)deleteIndex;
- (void)_handleWillAnimatePageDeletion:(NSInteger)index destinationIndex:(NSInteger)destinationIndex;
- (NSInteger)_indexOfPage:(LWPageView*)pageView;
- (LWPageView*)_pageForIndex:(NSInteger)index;
- (void)_purgeViewControllerForPageAtIndex:(NSInteger)index;
- (void)_recyclePage:(LWPageView*)pageView;
- (BOOL)_shouldEnableScrolling;
- (void)_tearDownPageDeletion;
- (void)_updateScrollViewHandlers;
- (UIViewController*)_viewControllerForPageAtIndex:(NSInteger)index;
- (void)activate;
- (void)deactivate;
- (void)cancelPageDeletion;
- (void)cancelPageDeletionAnimated:(BOOL)animated;
- (void)confirmPageDeletion;
- (NSInteger)currentPageIndex;
- (void)ensureViewControllerForPageAtIndex:(NSInteger)index;
- (NTKFaceViewController*)pageViewControllerAtIndex:(NSInteger)index;
- (void)reloadPages;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setDataSource:(nullable id <LWPageScrollViewControllerDataSource>)dataSource;
- (void)setDelegate:(nullable id <LWPageScrollViewControllerDelegate>)delegate;
- (void)setDeleteConfirmationView:(UIView*)deleteConfirmationView;
- (void)setScrollEnabled:(BOOL)enabled;
- (void)updatePageBehaviors;
- (void)updateScrollingEnabled;

@end

NS_ASSUME_NONNULL_END