//
//  LWClockView.m
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#define CLAMP(value, min, max) (value - min) / (max - min)

#import <AudioToolbox/AudioServices.h>

#import "LWClockView.h"

#import "Core/LWClockViewDelegate.h"

@interface UIDevice (Private)
- (BOOL)_supportsForceTouch;
@end

@implementation LWClockView 

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		// [self setClipsToBounds:YES];
		
		_longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
		[self addGestureRecognizer:_longPressGesture];
		
		_orbZoomEnabled = YES;
	}
	
	return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	return [self.delegate hitTest:point withEvent:event];
}

#pragma mark - Instance Methods

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender {
	if (_orbZoomEnabled && sender.state == UIGestureRecognizerStateBegan) {
		AudioServicesPlaySystemSound(1520);
		[self.delegate beginZoom];
		
		[UIView animateWithDuration:0.2 animations:^{
			[self.delegate setZoomProgress:1.0];
		} completion:^(BOOL finished) {
			[self.delegate endZoom:YES];
		}];
	}
}

- (void)handleTouch:(UITouch*)touch {
	if (!_orbZoomEnabled) return;
	if (![self touchIsForceTouch:touch]) return;
	
	CGFloat force = touch.force / touch.maximumPossibleForce;
	CGFloat clampedForce = MIN(MAX(CLAMP(force, 0.25, 1), 0), 1);
	
	if (touch.type == UITouchTypeStylus) {
		clampedForce = MIN(MAX(CLAMP(force, 0.1, 0.35), 0), 1);
	}
	
	[self.delegate setZoomProgress:clampedForce];
	
	if (clampedForce >= 1.0) {
		AudioServicesPlaySystemSound(1520);
		[self.delegate endZoom:YES];
		[_longPressGesture setEnabled:YES];
	}
}

- (void)handleTouchEnded:(UITouch*)touch {
	[_longPressGesture setEnabled:YES];
	
	if (!_orbZoomEnabled) return;
	if (![self touchIsForceTouch:touch]) return;
	
	// [UIView animateWithDuration:0.2 animations:^{
	// 	[self.delegate setZoomProgress:0];
	// } completion:^(BOOL finished) {
		[self.delegate endZoom:NO];
	// }];
}

#pragma mark - Force Touch

- (BOOL)touchIsForceTouch:(UITouch*)touch {
	return ([self.traitCollection forceTouchCapability] == UIForceTouchCapabilityAvailable &&
		[UIDevice.currentDevice _supportsForceTouch]) ||
		([UIDevice.currentDevice.model hasPrefix:@"iPad"] &&
		touch.type == UITouchTypeStylus);
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];
	
	if (!_orbZoomEnabled) return;
	
	UITouch* touch = touches.allObjects.firstObject;
	if ([self touchIsForceTouch:touch]) {
		[_longPressGesture setEnabled:NO];
		
		if (touch.force > 0.25) {
			[self.delegate beginZoom];
			[self handleTouch:touch];
		}
	} else {
		[_longPressGesture setEnabled:YES];
	}
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	[super touchesMoved:touches withEvent:event];
	
	if (!_orbZoomEnabled) return;
	
	UITouch* touch = touches.allObjects.firstObject;
	if ([self touchIsForceTouch:touch]) {
		[self handleTouch:touch];
	}
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	[super touchesEnded:touches withEvent:event];
	
	if (!_orbZoomEnabled) return;

	UITouch* touch = touches.allObjects.firstObject;
	if ([self touchIsForceTouch:touch]) {
		[self handleTouchEnded:touch];
	}
}

- (void)touchesCancelled:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	[self touchesEnded:touches withEvent:event];
}

@end