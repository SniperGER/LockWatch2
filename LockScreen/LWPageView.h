//
//  LWPageView.h
//  LockWatch2
//
//  Created by janikschmidt on 1/15/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWPageDelegate;
@class CLKDevice;

@interface LWPageView : UIScrollView <UIScrollViewDelegate> {
	CLKDevice* _device;
	UITapGestureRecognizer* _tapGesture;
}

@property (nonatomic) id <LWPageDelegate> pageDelegate;
@property (nonatomic) UIView* contentView;
@property (nonatomic) UIView* outlineView;
@property (nonatomic) CGSize contentViewSize;
@property (nonatomic) CGSize pageSize;
@property (nonatomic) CGFloat contentAlpha;
@property (nonatomic) CGFloat outlineAlpha;
@property (nonatomic) UIEdgeInsets outlineInsets;
@property (nonatomic) CGFloat outlineCornerRadius;

- (void)applyConfiguration;

@end