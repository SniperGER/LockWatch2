//
// LWBandSelectionViewController.h
// LockWatch [SSH: janiks-mac-mini.local]
//
// Created by janikschmidt on 9/11/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Preferences/PSDetailController.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWBandSelectionViewController : PSDetailController <UIScrollViewDelegate> {
	NSBundle* _localizableBundle;
	NSDictionary* _frameAssets;
	NSArray* _bandAssets;
	
	UISegmentedControl* _segmentedControl;
	UIScrollView* _frameScrollView;
	UIScrollView* _bandScrollView;
	UILabel* _frameLabel;
	UILabel* _bandLabel;
}

@end

NS_ASSUME_NONNULL_END