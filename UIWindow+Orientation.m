//
// UIWindow+Orientation.m
// LockWatch
//
// Created by janikschmidt on 6/19/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "UIWindow+Orientation.h"

@implementation UIWindow (Orientation)

+ (BOOL)isLandscapeOrientation {
	if (@available(iOS 13.0, *)) {
		return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.windows.firstObject.windowScene.interfaceOrientation);
	} else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
#pragma GCC diagnostic pop
	}
}

@end