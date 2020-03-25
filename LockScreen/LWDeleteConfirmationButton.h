//
// LWDeleteConfirmationButton.h
// LockWatch2
//
// Created by janikschmidt on 2/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLKDevice;

@interface LWDeleteConfirmationButton : UIControl {
	CLKDevice *_device;
    UIImageView *_deleteIconView;
    UILabel *_deleteLabel;
}

- (instancetype)initWithFrame:(CGRect)frame;
- (void)layoutSubviews;
- (void)setHighlighted:(BOOL)highlighted;
- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END