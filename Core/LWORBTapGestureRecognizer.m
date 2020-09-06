//
// LWORBTapGestureRecognizer.m
// LockWatch2
//
// Created by janikschmidt on 1/24/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWORBTapGestureRecognizer.h"

#import "Core/LWORBTapGestureRecognizerDelegate.h"

@interface UITouch (Private)
@property (nonatomic, readonly) CGFloat _pressure;
@property (nonatomic, readonly) CGFloat _maximumPossiblePressure;
@end

@implementation LWORBTapGestureRecognizer

- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action {
	if (self = [super initWithTarget:target action:action]) {
		[self reset];
	}
	
	return self;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	return NO;
}

- (void)reset {
	_progress = 0;
	
	_progressMin = 0.0;
	_progressLatch = 1.0;
	_progressMax = 1.2;
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	if (!_orbDelegate.isORBTapGestureAllowed) {
		[self setState:UIGestureRecognizerStateFailed];
		return;
	}
	
	[self setState:UIGestureRecognizerStatePossible];
	
	UITouch* touch = touches.anyObject;
	_touchStartLocation = [touch locationInView:self.view];
	
#if TARGET_OS_SIMULATOR
	_usingLongPress = YES;
#else
	_usingLongPress = (touch.type != UITouchTypeStylus && UIScreen.mainScreen.traitCollection.forceTouchCapability != UIForceTouchCapabilityAvailable);
#endif
	
	if (_usingLongPress) {
		[self _updateLongPressForTouchesBegan:touches event:event];
	} else {
		CGFloat force = touch._pressure / touch._maximumPossiblePressure;
		
		if (touch.type == UITouchTypeStylus) {
			force = MIN(MAX(CLAMP(force, 0.2, 0.45), 0), 1);
		} else {
			force = MIN(MAX(CLAMP(force, 0.2, 1), 0), 1);
		}
		
		[self _updateWithProgress:force];
	}
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	if (!_orbDelegate.isORBTapGestureAllowed) {
		[self setState:UIGestureRecognizerStateFailed];
		return;
	}
	
	if (!_shouldAllowTouchMove) {
		if ([self _touchMovedTooFarFromStartPoint:touches.anyObject]) {
			[self setState:UIGestureRecognizerStateFailed];
			[self _cleanup];
			
			return;
		}
	}
	
	if (_usingLongPress) return;
	[self _updateWithTouches:touches event:event];
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	if (!_orbDelegate.isORBTapGestureAllowed) {
		[self setState:UIGestureRecognizerStateFailed];
		return;
	}
	
	if (_usingLongPress) {
		[self _updateLongPressForTouchesEnded:touches event:event];
	}
	
	if (self.state != UIGestureRecognizerStateBegan && self.state != UIGestureRecognizerStateChanged) {
		[self setState:UIGestureRecognizerStateFailed];
	} else {
		[self setState:UIGestureRecognizerStateEnded];
	}
	
	[self _cleanup];
}

#pragma mark - Instance Methods

- (void)_cleanup {
	if (_usingLongPress) {
		[self _clearLongPressProgressTimer];
	}
	
	_progress = 0;
}

- (void)_cleanupLongPressGesture {
	_longPressGesturesToCancel = nil;
	_longPressTouches = nil;
	_longPressTouchesBeganEvent = nil;
}

- (void)_clearLongPressProgressTimer {
	[_longPressProgressTimer invalidate];
	_longPressProgressTimer = nil;
	
	[self _cleanupLongPressGesture];
}

- (NSArray*)_gestureRecognizersForTouches:(NSSet<UITouch*>*)touches {
	NSMutableArray* gestureRecognizers = [[[touches anyObject] gestureRecognizers] mutableCopy];
	[gestureRecognizers removeObject:self];
	
	return gestureRecognizers;
}

- (CGFloat)_longPressProgress {
	return MIN(MAX(LERP(0, 1.2, ((CACurrentMediaTime() - _longPressStartTime) - 0.65) / 0.4), _progressMin), _progressMax);
}

- (void)_scheduleLongPressProgressTimerWithDelay:(CGFloat)delay {
	[_longPressProgressTimer invalidate];
	
	_longPressProgressTimer = [NSTimer scheduledTimerWithTimeInterval:delay repeats:YES block:^(NSTimer* timer) {
		CGFloat progress = [self _longPressProgress];
		[self _updateWithProgress:progress];
		
		if (progress < _progressMax) {
			[self _scheduleLongPressProgressTimerWithDelay:60 / 1000];
		} else {
			[self _clearLongPressProgressTimer];
		}
	}];
}

- (BOOL)_touchMovedTooFarFromStartPoint:(UITouch*)touch {
	CGPoint touchLocation = [touch locationInView:self.view];
	
	CGFloat distanceX = (touchLocation.x - _touchStartLocation.x);
	CGFloat distanceY = (touchLocation.y - _touchStartLocation.y);
	CGFloat distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2));
	
	return touch.type == UITouchTypeStylus ? distance > 25 : distance > 10;
}

- (void)_updateLongPressForTouchesBegan:(NSSet<UITouch*>*)touches event:(UIEvent*)event {
	_longPressStartTime = CACurrentMediaTime();
	
	[self _scheduleLongPressProgressTimerWithDelay:0.65];
	
	_longPressTouches = touches;
	_longPressTouchesBeganEvent = event;
	_longPressGesturesToCancel = [self _gestureRecognizersForTouches:touches];
}

- (void)_updateLongPressForTouchesEnded:(NSSet<UITouch*>*)touches event:(UIEvent*)event {
	[self _updateWithProgress:[self _longPressProgress]];
}

- (void)_updateWithProgress:(CGFloat)progress {
	if (self.state <= UIGestureRecognizerStateChanged) {
		if (self.state == UIGestureRecognizerStatePossible) {
			if (progress > _progressMin) {
				_hasLatched = NO;
				[self setState:UIGestureRecognizerStateBegan];
				_progress = progress;
			}
		} else if (self.state > UIGestureRecognizerStatePossible) {
			if (progress != _progress) {
				[self setState:UIGestureRecognizerStateChanged];
			}
			
			_progress = progress;
			
			if (progress >= _progressLatch && _hasLatched == NO) {
				_hasLatched = YES;
				
				if ([_orbDelegate respondsToSelector:@selector(ORBTapGestureRecognizerDidLatch:)]) {
					[_orbDelegate ORBTapGestureRecognizerDidLatch:self];
				}
			}
		} else {
			_progress = progress;
		}
	}
}

- (void)_updateWithTouches:(NSSet<UITouch*>*)touches event:(UIEvent*)event {
	UITouch* touch = touches.anyObject;
	CGFloat force = (touch._pressure / touch._maximumPossiblePressure);
	
	if (touch.type == UITouchTypeStylus) {
		force = MIN(MAX(CLAMP(force, 0.2, 0.45), 0), 1);
	} else {
		force = MIN(MAX(CLAMP(force, 0.2, 1), 0), 1);
	}

	force = force * _progressMax;
	
	if (self.state == UIGestureRecognizerStatePossible) {
		if (force > _progressMin) {
			
		}
	}
	
	[self _updateWithProgress:force];
}

@end