//
// LWORBTapGestureRecognizer.h
// LockWatch2
//
// Created by janikschmidt on 1/25/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWORBTapGestureRecognizer;

@protocol LWORBTapGestureRecognizerDelegate <NSObject>

@required
- (BOOL)isORBTapGestureAllowed;

@optional
- (void)ORBTapGestureRecognizerDidLatch:(LWORBTapGestureRecognizer*)orbRecognizer;

@end