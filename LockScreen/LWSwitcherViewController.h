//
//  LWSwitcherViewController.h
//  LockWatch2
//
//  Created by janikschmidt on 1/14/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import "LWPageScrollViewController.h"

@protocol LWPageScrollViewControllerDataSource;

@interface LWSwitcherViewController : LWPageScrollViewController

@property (nonatomic, readonly) BOOL animatingZoom;
@property (nonatomic, readonly) CGFloat zoomLevel;
@property (nonatomic) CGFloat zoomAnimationDuration;
@property (nonatomic) CGFloat interpageSpacingWhenZoomedOut;
@property (nonatomic) CGFloat interpageSpacingWhenZoomedIn;
// @property(nonatomic) CGFloat verticalOffsetFromCenterWhenZoomedOut;
@property (nonatomic) CGFloat pageWidthWhenZoomedOut;
@property (nonatomic, readonly) CGFloat currentPageScale;
@property (nonatomic) CGFloat pageScaleWhenZoomedOut;

- (void)beginIncrementalZoom;
- (CGFloat)currentPageScale;
- (void)setIncrementalZoomLevel:(CGFloat)zoomLevel;
- (void)endIncrementalZoom;
- (void)setDataSource:(id <LWPageScrollViewControllerDataSource>)dataSource;
- (void)updateInterpageSpacing;
- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated withAnimations:(void (^)())animations completion:(void (^)(BOOL finished))completion;
- (BOOL)zoomedOut;

@end