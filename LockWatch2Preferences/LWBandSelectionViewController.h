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
	NSArray* _bandAssets;
	NSDictionary* _caseAssets;
	
	NSUInteger _bandIndex;
	NSUInteger _caseIndex;
	
	UISegmentedControl* _segmentedControl;
	UIScrollView* _caseScrollView;
	UIScrollView* _bandScrollView;
	
	UIImageView* _leftBandImageView;
	UIImageView* _rightBandImageView;
	UIImageView* _leftCaseImageView;
	UIImageView* _rightCaseImageView;
	
	CGFloat _leftBandImageOffset;
	CGFloat _rightBandImageOffset;
	CGFloat _leftCaseImageOffset;
	CGFloat _rightCaseImageOffset;
	
	UILabel* _caseLabel;
	UILabel* _bandLabel;
}

@end

NS_ASSUME_NONNULL_END