//
// LWNowPlayingIndicatorProvider.h
// LockWatch
//
// Created by janikschmidt on 8/8/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWNowPlayingIndicatorProvider : CLKImageProvider

@property (nonatomic) BOOL paused;

+ (instancetype)nowPlayingIndicatorProviderWithTintColor:(nullable UIColor*)tintColor state:(NSInteger)state;

@end

NS_ASSUME_NONNULL_END