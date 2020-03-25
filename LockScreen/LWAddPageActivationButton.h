//
// LWAddPageActivationButton.h
// LockWatch2
//
// Created by janikschmidt on 2/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWAddPageActivationButton : UIButton {
	UIVisualEffectView* _effectView;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setFrame:(CGRect)frame;
- (void)setHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END