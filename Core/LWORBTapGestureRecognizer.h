//
// LWORBTapGestureRecognizer.h
// LockWatch2
//
// Created by janikschmidt on 1/24/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LWORBTapGestureRecognizerDelegate;

@interface LWORBTapGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate> {
	CGFloat _progressMin;
	CGFloat _progressLatch;
	CGFloat _progressMax;
	NSTimer* _longPressProgressTimer;
	double _longPressStartTime;
	CGPoint _touchStartLocation;
	UIEvent* _longPressTouchesBeganEvent;
	NSArray* _longPressGesturesToCancel;
	NSSet* _longPressTouches;
	CGFloat _progress;
}

@property (nonatomic) BOOL shouldAllowTouchMove;
@property (nonatomic) BOOL usingLongPress;
@property (nonatomic, weak) id <LWORBTapGestureRecognizerDelegate> orbDelegate;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, readonly) BOOL hasLatched;

- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action;
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer;
- (void)reset;
- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event;
- (void)_cleanup;
- (void)_cleanupLongPressGesture;
- (void)_clearLongPressProgressTimer;
- (NSArray*)_gestureRecognizersForTouches:(NSSet<UITouch*>*)touches;
- (CGFloat)_longPressProgress;
- (void)_scheduleLongPressProgressTimerWithDelay:(CGFloat)delay;
- (BOOL)_touchMovedTooFarFromStartPoint:(UITouch*)touch;
- (void)_updateLongPressForTouchesBegan:(NSSet<UITouch*>*)touches event:(UIEvent*)event;
- (void)_updateLongPressForTouchesEnded:(NSSet<UITouch*>*)touches event:(UIEvent*)event;
- (void)_updateWithProgress:(CGFloat)progress;
- (void)_updateWithTouches:(NSSet<UITouch*>*)touches event:(UIEvent*)event;

@end

NS_ASSUME_NONNULL_END