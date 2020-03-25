//
// LWPageDelegate.h
// LockWatch2
//
// Created by janikschmidt on 2/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWPageView;

@protocol LWPageDelegate <NSObject>

- (void)page:(LWPageView*)pageView didUpdateSwipeToDelete:(CGFloat)fraction;
- (void)page:(LWPageView*)pageView didEndSwipeToDelete:(BOOL)completed;
- (void)pageDidBeginSwipeToDelete:(LWPageView*)pageView;
- (void)pageWasSelected:(LWPageView*)pageView;

@end