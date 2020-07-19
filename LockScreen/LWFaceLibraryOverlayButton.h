//
// LWFaceLibraryOverlayButton.h
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWFaceLibraryOverlayButton : UIButton {
	UIVisualEffectView* _visualEffectView;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setHighlighted:(BOOL)highlighted;
- (void)_legibilitySettingsChanged;

@end

NS_ASSUME_NONNULL_END