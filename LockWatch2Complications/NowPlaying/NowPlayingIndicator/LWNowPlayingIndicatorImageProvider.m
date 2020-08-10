//
// LWNowPlayingIndicatorImageProvider.m
// LockWatch
//
// Created by janikschmidt on 8/8/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWNowPlayingIndicatorImageProvider.h"
#import "LWNowPlayingIndicatorView.h"

@implementation LWNowPlayingIndicatorImageProvider

+ (instancetype)nowPlayingIndicatorProviderWithTintColor:(UIColor*)tintColor state:(NSInteger)state {
	LWNowPlayingIndicatorImageProvider* provider = [LWNowPlayingIndicatorImageProvider imageProviderWithImageViewCreationHandler:^UIView* () {
		return [[LWNowPlayingIndicatorView alloc] initWithFrame:CGRectZero];
	}];
	
	[provider setPaused:(state == 1)];
	[provider setTintColor:tintColor];
	
	return provider;
}

@end