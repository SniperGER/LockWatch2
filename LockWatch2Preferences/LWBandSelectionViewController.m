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
	
	[self.view setClipsToBounds:YES];
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(applySelectedFrame)];
	[rightButton setEnabled:NO];
	[self.navigationItem setRightBarButtonItem:rightButton];
	
	_localizableBundle = [NSBundle bundleWithPath:LOCALIZABLE_BUNDLE_PATH];
	
	NSDictionary* assetsJSON = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"Bands" ofType:@"plist"]];
	NSString* sizeClass = [self.class deviceSizeClass];
	
	if (![self.class sizeClassSupportsFauxFrames:sizeClass]) return;

	_caseAssets = assetsJSON[@"frames"][sizeClass];
	_bandAssets = assetsJSON[@"bands"][assetsJSON[@"frames"][sizeClass][@"bands"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
			[[NSBundle bundleForClass:self.class] localizedStringForKey:@"CASE" value:nil table:@"Bands"],
			[[NSBundle bundleForClass:self.class] localizedStringForKey:@"BAND" value:nil table:@"Bands"]
		]];
		[_segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
		[_segmentedControl setSelectedSegmentIndex:0];
	}
	[self.navigationItem setTitleView:_segmentedControl];
	
	if (!_bandLabel) {
		_bandLabel = [self _newLabel];
		[_bandLabel setFont:[UIFont systemFontOfSize:14]];
		[self.view addSubview:_bandLabel];
	}
	
	if (!_bandScrollView && [_bandAssets count]) {
		_bandScrollView = [self _newScrollView];
		[_bandScrollView setDelegate:self];
		[self.view addSubview:_bandScrollView];
		
		NSDictionary* bandImageNames = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"][@"bandImageNames"];
		
		[_bandAssets enumerateObjectsUsingBlock:^(NSDictionary* asset, NSUInteger index, BOOL* stop) {
			if ([bandImageNames objectForKey:[self.class deviceSizeClass]] && [asset[@"asset"] isEqualToString:[bandImageNames objectForKey:[self.class deviceSizeClass]]]) {
				_bandIndex = index;
				*stop = YES;
			}
			
			// UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){{ CGRectGetWidth(_bandScrollView.bounds) * index, 0 }, _bandScrollView.bounds.size }];
			// [imageView setImage:[UIImage imageNamed:asset[@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
			
			// [_bandScrollView addSubview:imageView];
		}];
		
		[_bandScrollView setContentSize:(CGSize){ CGRectGetWidth(_bandScrollView.bounds) * _bandAssets.count, CGRectGetHeight(_bandScrollView.bounds) }];
		if (_bandIndex >= 0) {
			[_bandScrollView setContentOffset:(CGPoint){ CGRectGetWidth(_bandScrollView.bounds) * _bandIndex, 0 }];
			[_bandLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:[_bandAssets objectAtIndex:_bandIndex][@"label"] value:nil table:@"Bands"]];
		}
		
		_leftBandImageView = [self _newImageView];
		[_bandScrollView addSubview:_leftBandImageView];
		
		_rightBandImageView = [self _newImageView];
		[_bandScrollView addSubview:_rightBandImageView];
		
		[NSLayoutConstraint activateConstraints:@[
			[_bandScrollView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[_bandScrollView.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[_bandScrollView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
			[_bandScrollView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
			[_bandScrollView.widthAnchor constraintLessThanOrEqualToConstant:375],
			[_bandScrollView.heightAnchor constraintEqualToAnchor:_bandScrollView.widthAnchor],
			[_bandScrollView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
			[_bandScrollView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
		]];
	}
	
	if (!_caseLabel) {
		_caseLabel = [self _newLabel];
		[_caseLabel setFont:[UIFont systemFontOfSize:16]];
		[self.view addSubview:_caseLabel];
	}
	
	if (!_caseScrollView && [_caseAssets[@"assets"] count]) {
		_caseScrollView = [self _newScrollView];
		[_caseScrollView setDelegate:self];
		[self.view addSubview:_caseScrollView];
		
		NSDictionary* caseImageNames = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.lockwatch2.plist"][@"caseImageNames"];
		
		[_caseAssets[@"assets"] enumerateObjectsUsingBlock:^(NSDictionary* asset, NSUInteger index, BOOL* stop) {
			if ([caseImageNames objectForKey:[self.class deviceSizeClass]] && [asset[@"asset"] isEqualToString:[caseImageNames objectForKey:[self.class deviceSizeClass]]]) {
				_caseIndex = index;
				*stop = YES;
			}
			
	// 		UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){{ CGRectGetWidth(_caseScrollView.bounds) * index, 0 }, _caseScrollView.bounds.size }];
	// 		[imageView setImage:[UIImage imageNamed:asset[@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
			
	// 		[_caseScrollView addSubview:imageView];
		}];
		
		[_caseScrollView setContentSize:(CGSize){ CGRectGetWidth(_caseScrollView.bounds) * [_caseAssets[@"assets"] count], CGRectGetHeight(_caseScrollView.bounds) }];
		if (_caseIndex >= 0) {
			[_caseScrollView setContentOffset:(CGPoint){ CGRectGetWidth(_caseScrollView.bounds) * _caseIndex, 0 }];
				[_caseLabel setText:[NSString stringWithFormat:@"%@ %@", 
				[[NSBundle bundleForClass:self.class] localizedStringForKey:_caseAssets[@"prefix"] value:nil table:@"Bands"],
				[[NSBundle bundleForClass:self.class] localizedStringForKey:[_caseAssets[@"assets"] objectAtIndex:_caseIndex][@"label"] value:nil table:@"Bands"]
			]];
		}
		
		_leftCaseImageView = [self _newImageView];
		[_caseScrollView addSubview:_leftCaseImageView];
		
		_rightCaseImageView = [self _newImageView];
		[_caseScrollView addSubview:_rightCaseImageView];
		
		[NSLayoutConstraint activateConstraints:@[
			[_caseScrollView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
			[_caseScrollView.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
			[_caseScrollView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
			[_caseScrollView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
			[_caseScrollView.widthAnchor constraintLessThanOrEqualToConstant:375],
			[_caseScrollView.heightAnchor constraintEqualToAnchor:_caseScrollView.widthAnchor],
			[_caseScrollView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
			[_caseScrollView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
		]];
	}
	
	if (![_bandAssets count] || ![_caseAssets[@"assets"] count]) {
		[_caseLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:@"DEVICE_FRAME_NOT_SUPPORTED" value:nil table:@"Bands"]];
		[_segmentedControl setEnabled:NO];
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
		
		
		[NSLayoutConstraint activateConstraints:@[
			[_caseLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:24],
			[_caseLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-24],
			[_caseLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
		]];
	} else {
		[NSLayoutConstraint activateConstraints:@[
			[_caseLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:24],
			[_caseLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-24],
			[_caseLabel.topAnchor constraintEqualToAnchor:_bandScrollView.bottomAnchor constant:24],
			
			[_bandLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:24],
			[_bandLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-24],
			[_bandLabel.topAnchor constraintEqualToAnchor:_caseLabel.bottomAnchor],
		]];
	}
	
	[self.view bringSubviewToFront:_caseLabel];
	[self.view bringSubviewToFront:_bandLabel];
	
	if ([self _isValidPageIndex:_bandIndex forScrollView:_bandScrollView]) {
		[self setLeftBandImageOffset:(_bandIndex * CGRectGetWidth(_bandScrollView.bounds))];
		[_leftBandImageView setImage:[self bandImageForIndex:_bandIndex]];
	} else {
		[_leftBandImageView setImage:nil];
	}
	
	if ([self _isValidPageIndex:(_bandIndex + 1) forScrollView:_bandScrollView]) {
		[self setRightBandImageOffset:((_bandIndex + 1) * CGRectGetWidth(_bandScrollView.bounds))];
		[_rightBandImageView setImage:[self bandImageForIndex:(_bandIndex + 1)]];
	} else {
		[_rightBandImageView setImage:nil];
	}
	
	if ([self _isValidPageIndex:_caseIndex forScrollView:_caseScrollView]) {
		[self setLeftCaseImageOffset:(_caseIndex * CGRectGetWidth(_caseScrollView.bounds))];
		[_leftCaseImageView setImage:[self caseImageForIndex:_caseIndex]];
	} else {
		[_leftCaseImageView setImage:nil];
	}
	
	if ([self _isValidPageIndex:(_caseIndex + 1) forScrollView:_caseScrollView]) {
		[self setRightCaseImageOffset:((_caseIndex + 1) * CGRectGetWidth(_caseScrollView.bounds))];
		[_rightCaseImageView setImage:[self caseImageForIndex:(_caseIndex + 1)]];
	} else {
		[_rightCaseImageView setImage:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self segmentedControlDidChange:_segmentedControl];
	
	// if ([_caseScrollView isUserInteractionEnabled]) {
	// 	[_caseScrollView flashScrollIndicators];
	// } else if ([_bandScrollView isUserInteractionEnabled]) {
	// 	[_bandScrollView flashScrollIndicators];
	// }
}

- (void)viewDidLayoutSubviews {
	[_leftBandImageView setCenter:(CGPoint){
		(CGRectGetWidth(_bandScrollView.bounds) / 2) + _leftBandImageOffset,
		CGRectGetMidY(_bandScrollView.bounds)
	}];
	
	[_rightBandImageView setCenter:(CGPoint){
		(CGRectGetWidth(_bandScrollView.bounds) / 2) + _rightBandImageOffset,
		CGRectGetMidY(_bandScrollView.bounds)
	}];
	
	[_leftCaseImageView setCenter:(CGPoint){
		(CGRectGetWidth(_caseScrollView.bounds) / 2) + _leftCaseImageOffset,
		CGRectGetMidY(_caseScrollView.bounds)
	}];
	
	[_rightCaseImageView setCenter:(CGPoint){
		(CGRectGetWidth(_caseScrollView.bounds) / 2) + _rightCaseImageOffset,
		CGRectGetMidY(_caseScrollView.bounds)
	}];
}

#pragma mark - Instance Methods

- (BOOL)_isValidPageIndex:(NSInteger)pageIndex forScrollView:(UIScrollView*)scrollView {
	if (scrollView == _bandScrollView) {
		return pageIndex >= 0 && [_bandAssets count] > pageIndex;
	} else if (scrollView == _caseScrollView) {
		return pageIndex >= 0 && [_caseAssets[@"assets"] count] > pageIndex;
	}
	
	return NO;
}

- (UIImageView*)_newImageView {
	UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){ CGPointZero, { MIN(CGRectGetWidth(self.view.bounds), 375), MIN(CGRectGetWidth(self.view.bounds), 375) }}];
	return imageView;
}

- (UILabel*)_newLabel {
	UILabel* label = [UILabel new];
	[label setTranslatesAutoresizingMaskIntoConstraints:NO];
	[label setNumberOfLines:0];
	[label setLineBreakMode:NSLineBreakByWordWrapping];
	[label setTextAlignment:NSTextAlignmentCenter];
	
	return label;
}

- (UIScrollView*)_newScrollView {
	UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){ CGPointZero, { MIN(CGRectGetWidth(self.view.bounds), 375), MIN(CGRectGetWidth(self.view.bounds), 375) }}];
	[scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[scrollView setClipsToBounds:NO];
	[scrollView setPagingEnabled:YES];
	[scrollView setShowsVerticalScrollIndicator:NO];
	
	return scrollView;
}

- (void)applySelectedFrame {
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	
	NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	NSMutableDictionary* bandImageNames = [settings[@"bandImageNames"] mutableCopy];
	NSMutableDictionary* caseImageNames = [settings[@"caseImageNames"] mutableCopy];
	
	[bandImageNames setObject:[_bandAssets objectAtIndex:_bandIndex][@"asset"] forKey:[self.class deviceSizeClass]];
	[caseImageNames setObject:[_caseAssets[@"assets"] objectAtIndex:_caseIndex][@"asset"] forKey:[self.class deviceSizeClass]];
	
	[settings setObject:bandImageNames forKey:@"bandImageNames"];
	[settings setObject:caseImageNames forKey:@"caseImageNames"];
	
	[settings writeToFile:PREFERENCES_PATH atomically:YES];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ml.festival.lockwatch2/WatchFrameSelected"), NULL, NULL, YES);
}

- (UIImage*)bandImageForIndex:(NSInteger)index {
	if ([self _isValidPageIndex:index forScrollView:_bandScrollView]) {
		return [UIImage imageNamed:[_bandAssets objectAtIndex:index][@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
	}
	
	return nil;
}

- (UIImage*)caseImageForIndex:(NSInteger)index {
	if ([self _isValidPageIndex:index forScrollView:_caseScrollView]) {
		return [UIImage imageNamed:[_caseAssets[@"assets"] objectAtIndex:index][@"asset"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
	}
	
	return nil;
}

- (void)segmentedControlDidChange:(UISegmentedControl*)segmentedControl {
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			[_caseScrollView setUserInteractionEnabled:YES];
			[_caseScrollView setClipsToBounds:NO];
			
			[_bandScrollView setUserInteractionEnabled:NO];
			[_bandScrollView setClipsToBounds:YES];
			
			[_caseScrollView flashScrollIndicators];
			break;
		case 1:
			[_caseScrollView setUserInteractionEnabled:NO];
			[_caseScrollView setClipsToBounds:YES];
			
			[_bandScrollView setUserInteractionEnabled:YES];
			[_bandScrollView setClipsToBounds:NO];
			
			[_bandScrollView flashScrollIndicators];
			break;
		default: break;
	}
}

- (void)setLeftBandImageOffset:(CGFloat)leftBandImageOffset {
	_leftBandImageOffset = leftBandImageOffset;
	
	[self.view setNeedsLayout];
}

- (void)setRightBandImageOffset:(CGFloat)rightBandImageOffset {
	_rightBandImageOffset = rightBandImageOffset;
	
	[self.view setNeedsLayout];
}

- (void)setLeftCaseImageOffset:(CGFloat)leftCaseImageOffset {
	_leftCaseImageOffset = leftCaseImageOffset;
	
	[self.view setNeedsLayout];
}

- (void)setRightCaseImageOffset:(CGFloat)rightCaseImageOffset {
	_rightCaseImageOffset = rightCaseImageOffset;
	
	[self.view setNeedsLayout];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
	NSInteger halfPage = (scrollView.contentOffset.x + (CGRectGetWidth(scrollView.bounds) / 2)) / CGRectGetWidth(scrollView.bounds);
	
	if (scrollView == _bandScrollView) {
		page = MIN(MAX(page, 0), [_bandAssets count] - 1);
		halfPage = MIN(MAX(halfPage, 0), [_bandAssets count] - 1);
		
		if ([self _isValidPageIndex:page forScrollView:_bandScrollView]) {
			[self setLeftBandImageOffset:(page * CGRectGetWidth(_bandScrollView.bounds))];
			[_leftBandImageView setImage:[self bandImageForIndex:page]];
		} else {
			[_leftBandImageView setImage:nil];
		}
		
		if ([self _isValidPageIndex:(page + 1) forScrollView:_bandScrollView]) {
			[self setRightBandImageOffset:((page + 1) * CGRectGetWidth(_bandScrollView.bounds))];
			[_rightBandImageView setImage:[self bandImageForIndex:(page + 1)]];
		} else {
			[_leftBandImageView setImage:nil];
		}
		
		[_bandLabel setText:[[NSBundle bundleForClass:self.class] localizedStringForKey:[_bandAssets objectAtIndex:halfPage][@"label"] value:nil table:@"Bands"]];
	} else if (scrollView == _caseScrollView) {
		page = MIN(MAX(page, 0), [_caseAssets[@"assets"] count] - 1);
		halfPage = MIN(MAX(halfPage, 0), [_caseAssets[@"assets"] count] - 1);
		
		if ([self _isValidPageIndex:page forScrollView:_caseScrollView]) {
			[self setLeftCaseImageOffset:(page * CGRectGetWidth(_caseScrollView.bounds))];
			[_leftCaseImageView setImage:[self caseImageForIndex:page]];
		} else {
			[_leftCaseImageView setImage:nil];
		}
		
		if ([self _isValidPageIndex:(page + 1) forScrollView:_caseScrollView]) {
			[self setRightCaseImageOffset:((page + 1) * CGRectGetWidth(_caseScrollView.bounds))];
			[_rightCaseImageView setImage:[self caseImageForIndex:(page + 1)]];
		} else {
			[_rightCaseImageView setImage:nil];
		}
		
		[_caseLabel setText:[NSString stringWithFormat:@"%@ %@", 
			[[NSBundle bundleForClass:self.class] localizedStringForKey:_caseAssets[@"prefix"] value:nil table:@"Bands"],
			[[NSBundle bundleForClass:self.class] localizedStringForKey:[_caseAssets[@"assets"] objectAtIndex:halfPage][@"label"] value:nil table:@"Bands"]
		]];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
	
	if (scrollView == _caseScrollView && page != _caseIndex) {
		_caseIndex = page;
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	} else if (scrollView == _bandScrollView && page != _bandIndex) {
		_bandIndex = page;
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	}
}

@end