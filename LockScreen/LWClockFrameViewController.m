//
// LWClockFrameViewController.m
// LockWatch
//
// Created by janikschmidt on 9/9/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoRegistry/NRDevice.h>

#import "LWClockFrameViewController.h"

#import "Core/LWPreferences.h"

@implementation LWClockFrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view setUserInteractionEnabled:NO];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	_bandImageView = [UIImageView new];
	[_bandImageView setContentMode:UIViewContentModeCenter];
	[_bandImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:_bandImageView];
	
	_caseImageView = [UIImageView new];
	[_caseImageView setContentMode:UIViewContentModeCenter];
	[_caseImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:_caseImageView];
	
	NSString* sizeClass = [NSString stringWithFormat:@"%ldh", [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenHeight"] integerValue]];
	BOOL showFrame = [[LWPreferences sharedInstance] showFrame];
	BOOL showBand = [[LWPreferences sharedInstance] showBand];
	
	if (showFrame) {
		[_caseImageView setImage:[UIImage imageNamed:[[LWPreferences sharedInstance] caseImageNames][sizeClass] inBundle:[NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH] compatibleWithTraitCollection:nil]];
	}
	
	if (showFrame && showBand) {
		[_bandImageView setImage:[UIImage imageNamed:[[LWPreferences sharedInstance] bandImageNames][sizeClass] inBundle:[NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH] compatibleWithTraitCollection:nil]];
	}
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.widthAnchor constraintEqualToConstant:455],
		[self.view.heightAnchor constraintEqualToConstant:455],
		[_bandImageView.widthAnchor constraintEqualToConstant:455],
		[_bandImageView.heightAnchor constraintEqualToConstant:455],
		[_caseImageView.widthAnchor constraintEqualToConstant:455],
		[_caseImageView.heightAnchor constraintEqualToConstant:455]
	]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchFrameChanged) name:@"ml.festival.lockwatch2/WatchFrameSelected" object:nil];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

#pragma mark - Instance Methods

- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated {
	if (!animated) {
		[self.view setAlpha:alpha];
		return;
	}
	
	[UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.1 options:0 animations:^{
		[self.view setAlpha:alpha];
	} completion:nil];
}

- (void)watchFrameChanged {
	NSString* sizeClass = [NSString stringWithFormat:@"%ldh", [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenHeight"] integerValue]];
	BOOL showFrame = [[LWPreferences sharedInstance] showFrame];
	BOOL showBand = [[LWPreferences sharedInstance] showBand];
	
	if (showFrame) {
		[_caseImageView setImage:[UIImage imageNamed:[[LWPreferences sharedInstance] caseImageNames][sizeClass] inBundle:[NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH] compatibleWithTraitCollection:nil]];
	} else {
		[_caseImageView setImage:nil];
	}
	
	if (showFrame && showBand) {
		[_bandImageView setImage:[UIImage imageNamed:[[LWPreferences sharedInstance] bandImageNames][sizeClass] inBundle:[NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH] compatibleWithTraitCollection:nil]];
	} else {
		[_bandImageView setImage:nil];
	}
}

@end