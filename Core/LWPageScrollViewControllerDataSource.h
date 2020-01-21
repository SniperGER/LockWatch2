@class LWPageScrollViewController;

@protocol LWPageScrollViewControllerDataSource <NSObject>

- (UIViewController*)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController viewControllerForPageAtIndex:(NSInteger)index;
- (NSInteger)pageScrollViewControllerNumberOfPages:(LWPageScrollViewController*)pageScrollViewController;

@end