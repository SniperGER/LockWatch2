//
// LWPageScrollViewControllerDelegate.h
// LockWatch2
//
// Created by janikschmidt on 1/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWPageScrollViewController, LWPageView;

@protocol LWPageScrollViewControllerDelegate <NSObject>

@optional
- (BOOL)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController canDeletePageAtIndex:(NSInteger)index;
- (BOOL)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController canMovePageAtIndex:(NSInteger)index;
- (BOOL)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController canSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController configurePage:(LWPageView*)pageView atIndex:(NSInteger)index;
- (CGSize)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController contentViewSizeForPageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didBeginSwipeToDeleteAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didDeletePageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didEndSwipeToDeleteAtIndex:(NSInteger)index deleted:(BOOL)deleted;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didMovePageAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didScrollToFraction:(CGFloat)fraction betweenIndex:(NSInteger)firstIndex andIndex:(NSInteger)secondIndex;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didScrollToOffset:(CGPoint)offset;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didScrollToPageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didScrollToPageAtIndex:(NSInteger)index toDeleteIndex:(NSInteger)deleteIndex;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didSelectPageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didUpdateSwipeToDeleteAtIndex:(NSInteger)index fraction:(CGFloat)fraction;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController pageDidAppearAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController pageDidDisappearAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController pageWillAppearAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController pageWillDisappearAtIndex:(NSInteger)index;
- (NSInteger)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController scrollDirectionForDeletedIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController willAnimatePageDeletion:(NSInteger)index destinationIndex:(NSInteger)destinationIndex;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController willDecelerateToIndex:(NSInteger)index;
- (void)pageScrollViewControllerDidAnimatePageDeletion:(LWPageScrollViewController*)pageScrollViewController;
- (void)pageScrollViewControllerDidScroll:(LWPageScrollViewController*)pageScrollViewController;
- (void)pageScrollViewControllerDidStartScrolling:(LWPageScrollViewController*)pageScrollViewController;
- (void)pageScrollViewControllerDidStopScrolling:(LWPageScrollViewController*)pageScrollViewController;
- (void)pageScrollViewControllerIsAnimatingPageDeletion:(LWPageScrollViewController*)pageScrollViewController;

@end