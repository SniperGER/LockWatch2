//
// LWNowPlayingIndicatorFullColorProvider.h
// LockWatch
//
// Created by janikschmidt on 8/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/ClockKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWNowPlayingIndicatorFullColorProvider : CLKFullColorImageProvider

@property (nonatomic) BOOL paused;

+ (instancetype)nowPlayingIndicatorFullColorProviderWithTintColor:(nullable UIColor*)tintColor state:(NSInteger)state;

@end

NS_ASSUME_NONNULL_END