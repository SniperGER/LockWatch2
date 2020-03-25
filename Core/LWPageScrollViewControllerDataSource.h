//
// LWPageScrollViewControllerDataSource.h
// LockWatch2
//
// Created by janikschmidt on 1/28/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWPageScrollViewController;

@protocol LWPageScrollViewControllerDataSource <NSObject>

- (UIViewController*)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController viewControllerForPageAtIndex:(NSInteger)index;
- (NSInteger)pageScrollViewControllerNumberOfPages:(LWPageScrollViewController*)pageScrollViewController;

@optional
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didPurgePageViewController:(UIViewController*)viewController;

@end