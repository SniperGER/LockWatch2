//
// LWBandSelectionViewController.m
// LockWatch [SSH: janiks-mac-mini.local]
//
// Created by janikschmidt on 9/11/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoRegistry/NRDevice.h>

#import "LWBandSelectionViewController.h"

@implementation LWBandSelectionViewController

+ (NSString*)deviceSizeClass {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"];
	BOOL isEmulatingDevice = [settings[@"isEmulatingDevice"] boolValue];
	NSString* sizeClass;
	
	if (isEmulatingDevice) {
		NSString* emulatedDeviceType = settings[@"emulatedDeviceType"];
		if ([emulatedDeviceType isEqualToString:@"Watch3,3"]) {
			sizeClass = @"340h";
		} else if ([emulatedDeviceType isEqualToString:@"Watch3,4"]) {
			sizeClass = @"390h";
		} else if ([emulatedDeviceType isEqualToString:@"Watch5,3"]) {
			sizeClass = @"394h";
		} else if ([emulatedDeviceType isEqualToString:@"Watch5,4"]) {
			sizeClass = @"448h";
		} 
	} else {
		sizeClass = [NSString stringWithFormat:@"%ldh", [[[[CLKDevice currentDevice] nrDevice] valueForProperty:@"mainScreenHeight"] integerValue]];
	}
	
	return sizeClass;
}

+ (BOOL)sizeClassSupportsFauxFrames:(NSString*)sizeClass {
	NSDictionary* assetsJSON = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:self] pathForResource:@"Bands" ofType:@"plist"]];
	return [assetsJSON[@"frames"] objectForKey:sizeClass] != nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(applySelectedFrame)];
	[rightButton setEnabled:NO];
	[self.navigationItem setRightBarButtonItem:rightButton];
	
	_localizableBundle = [NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH];
	
	NSDictionary* assetsJSON = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"Bands" ofType:@"plist"]];
	NSString* sizeClass = [self.class deviceSizeClass];
	
	if (![self.class sizeClassSupportsFauxFrames:sizeClass]) return;

	_frameAssets = assetsJSON[@"frames"][sizeClass];
	_bandAssets = assetsJSON[@"bands"][assetsJSON[@"frames"][sizeClass][@"bands"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
			[[NSBundle bundleForClass:self.class] localizedStringForKey:@"CASE" value:nil table:@"Bands"],
			[[NSBundle bundleForClass:self.class] localizedStringForKey:@"BAND" value:nil table:@"Bands"]
		]];
		[_segmentedControl addTarget:self action:@selector(segmentControlDidChange:) forControlEvents:UIControlEventValueChanged];
		[_segmentedControl setSelectedSegmentIndex:0];
	}
	[self.navigationItem setTitleView:_segmentedControl];
	
	if (!_bandLabel) {
		_bandLabel = [UILabel new];
		[_bandLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_bandLabel setFont:[UIFont systemFontOfSize:14]];
		[_bandLabel setNumberOfLines:0];
		[_bandLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[_bandLabel setTextAlignment:NSTextAlignmentCenter];
		[self.view addSubview:_bandLabel];
	}
	
	if (!_bandScrollView && [_bandAssets count]) {
		_bandScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){ CGPointZero, { CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) }}];
		[_bandScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_bandScrollView setPagingEnabled:YES];
		[_bandScrollView setShowsVerticalScrollIndicator:NO];
		[_bandScrollView setDelegate:self];
		[self.view addSubview:_bandScrollView];
		
		NSDictionary* bandImageNames = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"][@"bandImageNames"];
		__block NSInteger bandIndex = -1;
		
		[_bandAssets enumerateObjectsUsingBlock:^(NSDictionary* asset, NSUInteger index, BOOL* stop) {
			if ([bandImageNames objectForKey:[self.class deviceSizeClass]] && [asset[@"asset"] isEqualToString:[bandImageNames objectForKey:[self.class deviceSizeClass]]]) {
				bandIndex = index;
			}
			
			UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){{ CGRectGetWidth(_bandScrollView.bounds) * index, 0 }, _bandScrollView.bounds.size }];
			[imageView setImage:[UIImage imageNamed:asset[@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
			
			[_bandScrollView addSubview:imageView];
		}];
		
		[_bandScrollView setContentSize:(CGSize){ CGRectGetWidth(_bandScrollView.bounds) * _bandAssets.count, CGRectGetHeight(_bandScrollView.bounds) }];
		if (bandIndex >= 0) {
			[_bandScrollView setContentOffset:(CGPoint){ CGRectGetWidth(_bandScrollView.bounds) * bandIndex, 0 }];
			[_bandLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:[_bandAssets objectAtIndex:bandIndex][@"label"] value:nil table:@"Bands"]];
		}
		
		[NSLayoutConstraint activateConstraints:@[
			[_bandScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
			[_bandScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
			[_bandScrollView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
			[_bandScrollView.heightAnchor constraintEqualToAnchor:_bandScrollView.widthAnchor],
		]];
	}
	
	if (!_frameLabel) {
		_frameLabel = [UILabel new];
		[_frameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_frameLabel setFont:[UIFont systemFontOfSize:16]];
		[_frameLabel setNumberOfLines:0];
		[_frameLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[_frameLabel setTextAlignment:NSTextAlignmentCenter];
		[self.view addSubview:_frameLabel];
	}
	
	if (!_frameScrollView && [_frameAssets[@"assets"] count]) {
		_frameScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){ CGPointZero, { CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) }}];
		[_frameScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_frameScrollView setPagingEnabled:YES];
		[_frameScrollView setShowsVerticalScrollIndicator:NO];
		[_frameScrollView setDelegate:self];
		[self.view addSubview:_frameScrollView];
		
		NSDictionary* caseImageNames = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"][@"caseImageNames"];
		__block NSInteger caseIndex = -1;
		
		[_frameAssets[@"assets"] enumerateObjectsUsingBlock:^(NSDictionary* asset, NSUInteger index, BOOL* stop) {
			if ([caseImageNames objectForKey:[self.class deviceSizeClass]] && [asset[@"asset"] isEqualToString:[caseImageNames objectForKey:[self.class deviceSizeClass]]]) {
				caseIndex = index;
			}
			
			UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){{ CGRectGetWidth(_frameScrollView.bounds) * index, 0 }, _frameScrollView.bounds.size }];
			[imageView setImage:[UIImage imageNamed:asset[@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
			
			[_frameScrollView addSubview:imageView];
		}];
		
		[_frameScrollView setContentSize:(CGSize){ CGRectGetWidth(_frameScrollView.bounds) * [_frameAssets[@"assets"] count], CGRectGetHeight(_frameScrollView.bounds) }];
		if (caseIndex >= 0) {
			[_frameScrollView setContentOffset:(CGPoint){ CGRectGetWidth(_frameScrollView.bounds) * caseIndex, 0 }];
			[_frameLabel setText:[NSString stringWithFormat:@"%@ %@", 
			[[NSBundle bundleForClass:self.class] localizedStringForKey:_frameAssets[@"prefix"] value:nil table:@"Bands"],
			[[NSBundle bundleForClass:self.class] localizedStringForKey:[_frameAssets[@"assets"] objectAtIndex:caseIndex][@"label"] value:nil table:@"Bands"]
		]];
		}
		
		[NSLayoutConstraint activateConstraints:@[
			[_frameScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
			[_frameScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
			[_frameScrollView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
			[_frameScrollView.heightAnchor constraintEqualToAnchor:_frameScrollView.widthAnchor]
		]];
	}
	
	if (![_bandAssets count] || ![_frameAssets[@"assets"] count]) {
		[_frameLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:@"DEVICE_FRAME_NOT_SUPPORTED" value:nil table:@"Bands"]];
		[_segmentedControl setEnabled:NO];
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
		
		
		[NSLayoutConstraint activateConstraints:@[
			[_frameLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[_frameLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[_frameLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
		]];
	} else {
		[NSLayoutConstraint activateConstraints:@[
			[_frameLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[_frameLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[_frameLabel.topAnchor constraintEqualToAnchor:_frameScrollView.bottomAnchor constant:24],
			
			[_bandLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[_bandLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[_bandLabel.topAnchor constraintEqualToAnchor:_frameLabel.bottomAnchor],
		]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([_frameScrollView isUserInteractionEnabled]) {
		[_frameScrollView flashScrollIndicators];
	} else if ([_bandScrollView isUserInteractionEnabled]) {
		[_bandScrollView flashScrollIndicators];
	}
}

#pragma mark - Instance Methods

- (void)applySelectedFrame {
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	
	NSInteger bandIndex = _bandScrollView.contentOffset.x / _bandScrollView.frame.size.width;
	NSInteger frameIndex = _frameScrollView.contentOffset.x / _frameScrollView.frame.size.width;
	
	NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	NSMutableDictionary* bandImageNames = [settings[@"bandImageNames"] mutableCopy];
	NSMutableDictionary* caseImageNames = [settings[@"caseImageNames"] mutableCopy];
	
	[bandImageNames setObject:[_bandAssets objectAtIndex:bandIndex][@"asset"] forKey:[self.class deviceSizeClass]];
	[caseImageNames setObject:[_frameAssets[@"assets"] objectAtIndex:frameIndex][@"asset"] forKey:[self.class deviceSizeClass]];
	
	[settings setObject:bandImageNames forKey:@"bandImageNames"];
	[settings setObject:caseImageNames forKey:@"caseImageNames"];
	
	[settings writeToFile:PREFERENCES_PATH atomically:YES];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ml.festival.lockwatch2/WatchFrameSelected"), NULL, NULL, YES);
}

- (void)segmentControlDidChange:(UISegmentedControl*)segmentedControl {
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			[_frameScrollView setUserInteractionEnabled:YES];
			[_bandScrollView setUserInteractionEnabled:NO];
			
			[_frameScrollView flashScrollIndicators];
			break;
		case 1:
			[_frameScrollView setUserInteractionEnabled:NO];
			[_bandScrollView setUserInteractionEnabled:YES];
			
			[_bandScrollView flashScrollIndicators];
			break;
		default: break;
	}
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	[self.navigationItem.rightBarButtonItem setEnabled:YES];
	NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
	
	if (scrollView == _frameScrollView) {
		[_frameLabel setText:[NSString stringWithFormat:@"%@ %@", 
			[[NSBundle bundleForClass:self.class] localizedStringForKey:_frameAssets[@"prefix"] value:nil table:@"Bands"],
			[[NSBundle bundleForClass:self.class] localizedStringForKey:[_frameAssets[@"assets"] objectAtIndex:page][@"label"] value:nil table:@"Bands"]
		]];
	} else if (scrollView == _bandScrollView) {
		[_bandLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:[_bandAssets objectAtIndex:page][@"label"] value:nil table:@"Bands"]];
	}
}

@end