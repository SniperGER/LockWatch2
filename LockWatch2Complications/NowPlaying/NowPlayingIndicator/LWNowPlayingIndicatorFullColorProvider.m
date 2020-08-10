//
// LWNowPlayingIndicatorFullColorProvider.m
// LockWatch
//
// Created by janikschmidt on 8/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWNowPlayingIndicatorFullColorProvider.h"

@implementation LWNowPlayingIndicatorFullColorProvider

+ (instancetype)nowPlayingIndicatorFullColorProviderWithTintColor:(UIColor*)tintColor state:(NSInteger)state {
	LWNowPlayingIndicatorFullColorProvider* provider = [LWNowPlayingIndicatorFullColorProvider fullColorImageProviderWithImageViewClass:NSClassFromString(@"LWNowPlayingIndicatorView")];
	[provider setPaused:(state == 1)];
	[provider setTintColor:tintColor];
	
	return provider;
}

@end