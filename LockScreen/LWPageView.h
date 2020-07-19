//
// LWPageView.h
// LockWatch2
//
// Created by janikschmidt on 3/3/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LWPageDelegate;
@class CLKDevice;

@interface LWPageView : UIScrollView <UIScrollViewDelegate> {
	CLKDevice* _device;
    UITapGestureRecognizer* _tapGesture;
    UIVisualEffectView* _outlineView;
	UIView* _outlineInnerView;
	CAShapeLayer* _outlineViewMask;
    UIView* _overlayView;
	BOOL _swipingToDelete;
	CGPoint _targetContentOffset;
}

@property (nonatomic) BOOL allowsDelete;
@property (nonatomic) BOOL allowsSelect;
@property (nonatomic) CGSize contentViewSize;
@property (nonatomic) CGSize pageSize;
@property (nonatomic, retain) UIView* _Nullable contentView;
@property (nonatomic, weak) id <LWPageDelegate> pageDelegate;
@property (nonatomic) CGFloat contentAlpha;
@property (nonatomic) CGFloat outlineAlpha;
@property (nonatomic) UIEdgeInsets outlineInsets;
@property (nonatomic) CGFloat outlineCornerRadius;
@property (nonatomic) CGFloat outlineStrokeWidth;
@property (nonatomic) NSInteger layoutRule;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)layoutSubviews;
- (CGSize)sizeThatFits:(CGSize)size;
- (CGFloat)_deleteFractionForOffset:(CGPoint)offset;
- (void)_handleTap:(UIGestureRecognizer*)sender;
- (void)_handleScrollingStopped;
- (void)_legibilitySettingsChanged;
- (void)applyConfiguration;
- (void)cancelDelete:(BOOL)animated;
- (void)prepareForReuse;
- (void)setAllowsDelete:(BOOL)allowsDelete;
- (void)setAllowsSelect:(BOOL)allowsSelect;
- (void)setContentAlpha:(CGFloat)contentAlpha;
- (void)setContentView:(nullable UIView*)contentView;
- (void)setContentViewSize:(CGSize)contentViewSize;
- (void)setOutlineAlpha:(CGFloat)outlineAlpha;

@end

NS_ASSUME_NONNULL_END