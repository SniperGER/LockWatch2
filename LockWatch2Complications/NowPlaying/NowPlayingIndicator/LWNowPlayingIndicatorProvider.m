//
// LWNowPlayingIndicatorProvider.m
// LockWatch
//
// Created by janikschmidt on 8/8/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWNowPlayingIndicatorProvider.h"
#import "LWNowPlayingIndicatorView.h"

@implementation LWNowPlayingIndicatorProvider

+ (instancetype)nowPlayingIndicatorProviderWithTintColor:(UIColor*)tintColor state:(NSInteger)state {
	LWNowPlayingIndicatorProvider* provider = [LWNowPlayingIndicatorProvider imageProviderWithImageViewCreationHandler:^UIView* () {
		return [[LWNowPlayingIndicatorView alloc] initWithFrame:CGRectZero];
	}];
	
	[provider setPaused:(state == 1)];
	[provider setTintColor:tintColor];
	
	return provider;
}

@end