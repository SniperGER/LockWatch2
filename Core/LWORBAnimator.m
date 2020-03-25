//
// LWORBAnimator.m
// LockWatch2
//
// Created by janikschmidt on 1/25/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWORBAnimator.h"

#import "Core/LWORBTapGestureRecognizer.h"

@implementation LWORBAnimator

- (instancetype)initWithORBGestureRecognizer:(LWORBTapGestureRecognizer*)orbRecognizer {
	if (self = [super init]) {
		_orbRecognizer = orbRecognizer;
		[_orbRecognizer addTarget:self action:@selector(_gestureChanged:)];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)_gestureChanged:(UIGestureRecognizer*)gestureRecognizer {
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			[self _handleGestureBegan];
			break;
		case UIGestureRecognizerStateChanged:
			[self _handleGestureChanged];
			break;
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			[self _handleGestureEnded];
			break;
		default: break;
	}
}

- (void)_handleGestureBegan {
	_latched = NO;
	
	if (_beginHandler) {
		_beginHandler();
	}
}

- (void)_handleGestureChanged {
	if (!_latched && _orbRecognizer.hasLatched) {
		_latched = YES;
	}
	
	if (_orbRecognizer.progress > 0.0f && _progressHandler) {
		if (!_latched || (_latched && _orbRecognizer.progress >= 1.0)) {
			_progressHandler(_orbRecognizer.progress);
		} else {
			_progressHandler(1.0);
		}	
	}
}

- (void)_handleGestureEnded {
	if (!_latched) {
		if (_orbRecognizer.hasLatched) {
			_latched = YES;
		}
	}
	
	if (_endHandler) {
		[UIView animateWithDuration:0.1 animations:^{
			_progressHandler(_latched ? 1.0 : 0.0);
		} completion:^(BOOL finished) {
			_endHandler(_latched);
		}];
	}
}

@end