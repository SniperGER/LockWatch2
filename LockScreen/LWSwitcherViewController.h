//
// LWSwitcherViewController.h
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>
#import "LWPageScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWSwitcherViewController : LWPageScrollViewController {
	NSTimer* _zoomAnimationTimer;
}

@property (nonatomic, readonly) BOOL animatingZoom;
@property (nonatomic, readonly) CGFloat zoomLevel;
@property (nonatomic) CGFloat zoomAnimationDuration;
@property (nonatomic) CGFloat interpageSpacingWhenZoomedOut;
@property (nonatomic) CGFloat interpageSpacingWhenZoomedIn;
@property (nonatomic) CGFloat verticalOffsetFromCenterWhenZoomedOut;
@property (nonatomic) CGFloat pageWidthWhenZoomedOut;
@property (nonatomic, readonly) CGFloat currentPageScale;
@property (nonatomic) CGFloat pageScaleWhenZoomedOut;

- (instancetype)init;
- (instancetype)initWithScrollOrientation:(NSInteger)scrollOrientation;
- (void)viewDidLayoutSubviews;
- (BOOL)_canDeletePageAtIndex:(NSInteger)index;
- (CGRect)_frameForCenteredPage;
- (void)_setAnimatingZoom:(BOOL)animatingZoom;
- (BOOL)_shouldEnableScrolling;
- (void)_updateInterpageSpacing;
- (void)beginIncrementalZoom;
- (void)endIncrementalZoom;
- (void)setDataSource:(nullable id <LWPageScrollViewControllerDataSource>)dataSource;
- (void)setIncrementalZoomLevel:(CGFloat)zoomLevel;
- (BOOL)zoomedOut;
- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))block;
- (void)zoomInPageAtIndex:(NSInteger)index animated:(BOOL)animated withAnimations:(void (^_Nullable)())animations completion:(void (^_Nullable)(BOOL finished))block;

@end

NS_ASSUME_NONNULL_END