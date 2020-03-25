//
// LWFaceLibraryOverlayButton.m
// LockWatch2
//
// Created by janikschmidt on 3/17/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWFaceLibraryOverlayButton.h"

@implementation LWFaceLibraryOverlayButton

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
		[_visualEffectView setUserInteractionEnabled:NO];
		[_visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_visualEffectView setClipsToBounds:YES];
		[_visualEffectView.layer setCornerRadius:8];
		
#if __clang_major__ >= 9
		if (@available(iOS 13, *)) {
			[_visualEffectView.layer setCornerCurve:kCACornerCurveContinuous];
		}
#endif
		
		[self insertSubview:_visualEffectView atIndex:0];
		
		[NSLayoutConstraint activateConstraints:@[
			[_visualEffectView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[_visualEffectView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
			[_visualEffectView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
			[_visualEffectView.heightAnchor constraintEqualToAnchor:self.heightAnchor]
		]];
	}
	
	return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
	
	[UIView animateWithDuration:highlighted ? 0.0 : 0.2 animations:^{
		[self setAlpha:highlighted ? 0.2 : 1.0];
	}];
}

@end