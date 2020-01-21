@class LWPageScrollViewController;

@protocol LWPageScrollViewControllerDelegate <NSObject>

- (void)pageScrollViewControllerDidScroll:(LWPageScrollViewController*)pageScrollViewController;
- (CGSize)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController contentViewSizeForPageAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(LWPageScrollViewController*)pageScrollViewController didSelectPageAtIndex:(NSInteger)index;

@end