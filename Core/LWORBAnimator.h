//
// LWORBAnimator.h
// LockWatch2
//
// Created by janikschmidt on 1/25/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LWORBTapGestureRecognizer;

@interface LWORBAnimator : NSObject {
	LWORBTapGestureRecognizer* _orbRecognizer;
    BOOL _latched;
}

@property (nonatomic, copy) void (^beginHandler)();
@property (nonatomic, copy) void (^progressHandler)(CGFloat progress);
@property (nonatomic, copy) void (^endHandler)(BOOL latched);

- (instancetype)initWithORBGestureRecognizer:(LWORBTapGestureRecognizer*)orbRecognizer;
- (void)_gestureChanged:(UIGestureRecognizer*)gestureRecognizer;
- (void)_handleGestureBegan;
- (void)_handleGestureChanged;
- (void)_handleGestureEnded;

@end

NS_ASSUME_NONNULL_END