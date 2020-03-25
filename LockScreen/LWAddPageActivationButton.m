//
// LWAddPageActivationButton.m
// LockWatch2
//
// Created by janikschmidt on 2/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWAddPageActivationButton.h"

@implementation LWAddPageActivationButton

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setClipsToBounds:YES];
	
		_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
		[_effectView setFrame:frame];
		[_effectView setUserInteractionEnabled:NO];
		[self addSubview:_effectView];
		
		CAShapeLayer* mask = [CAShapeLayer layer];
		[mask setFillRule:kCAFillRuleEvenOdd];
		
		UIBezierPath* path = [UIBezierPath bezierPathWithRect:self.bounds];
		[path setUsesEvenOddFillRule:YES];
		[path moveToPoint:(CGPoint){ CGRectGetMidX(self.bounds) - 2.5, CGRectGetMidY(self.bounds) - 2.5 }];
		
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) - (2.5 + 10), CGRectGetMidY(self.bounds) - 2.5 }];
		[path addArcWithCenter:(CGPoint){ CGRectGetMidX(self.bounds) - (2.5 + 10), CGRectGetMidY(self.bounds)} radius:2.5 startAngle:-M_PI / 2 endAngle:M_PI / 2 clockwise:NO];
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) - 2.5, CGRectGetMidY(self.bounds) + 2.5 }];
		
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) - 2.5, CGRectGetMidY(self.bounds) + (2.5 + 10) }];
		[path addArcWithCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + (2.5 + 10) } radius:2.5 startAngle:-M_PI endAngle:0 clockwise:NO];
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) + 2.5, CGRectGetMidY(self.bounds) + 2.5 }];
		
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) + (2.5 + 10), CGRectGetMidY(self.bounds) + 2.5 }];
		[path addArcWithCenter:(CGPoint){ CGRectGetMidX(self.bounds) + (2.5 + 10), CGRectGetMidY(self.bounds)} radius:2.5 startAngle:M_PI / 2 endAngle:-M_PI / 2 clockwise:NO];
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) + 2.5, CGRectGetMidY(self.bounds) - 2.5 }];
		
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) + 2.5, CGRectGetMidY(self.bounds) - (2.5 + 10) }];
		[path addArcWithCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - (2.5 + 10) } radius:2.5 startAngle:0 endAngle:-M_PI clockwise:NO];
		[path addLineToPoint:(CGPoint){ CGRectGetMidX(self.bounds) - 2.5, CGRectGetMidY(self.bounds) - 2.5 }];
		
		[path closePath];
		
		[mask setPath:path.CGPath];
		[_effectView.layer setMask:mask];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	[_effectView setFrame:frame];
	[self.layer setCornerRadius:CGRectGetWidth(frame) / 2];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
	
	[UIView animateWithDuration:highlighted ? 0.0 : 0.2 animations:^{
		[self setAlpha:highlighted ? 0.2 : 1.0];
	}];
}

@end