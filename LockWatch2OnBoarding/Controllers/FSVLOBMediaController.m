//
// FSVLOBMediaController.m
// LockWatch
//
// Created by janikschmidt on 7/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

extern NSBundle* LWOLocalizableBundle();

#import "FSVLOBMediaController.h"

@class AVPlaybackContentContainerView, AVPlayerController, AVPlayerViewControllerContentView;

@interface AVPlayerViewController (Private)
- (AVPlayerViewControllerContentView*)contentView;
- (AVPlayerController*)playerController;
@end

@interface AVPlayerViewControllerContentView : UIView
- (AVPlaybackContentContainerView*)playbackContentContainerView;
@end

@interface AVPlaybackContentContainerView : UIView
@end

@interface AVPlayerController : NSObject
- (BOOL)isLooping;
- (void)setLooping:(BOOL)arg1;
- (BOOL)playing;
- (void)setPlaying:(BOOL)arg1;
@end



@implementation FSVLOBMediaController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (!self.flowItemDefinition[@"AssetPath"]) return;
	
	NSString* assetPath = [LWOLocalizableBundle() pathForResource:self.flowItemDefinition[@"AssetPath"] ofType:@"mov"];
	
	if (!assetPath) {
		assetPath = self.flowItemDefinition[@"AssetPath"];
	}
	if (!assetPath) return;
	
	AVURLAsset* asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:assetPath isDirectory:NO] options:nil];
	if (!asset) return;
	
	NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
	if (!tracks.count) return;
	
	AVAssetTrack* track = [tracks objectAtIndex:0];
	CGSize mediaSize = track.naturalSize;
	
	_playerItem = [AVPlayerItem playerItemWithAsset:asset];
	_videoPlayer = [AVQueuePlayer queuePlayerWithItems:@[ _playerItem ]];
	_playerLooper = [AVPlayerLooper playerLooperWithPlayer:_videoPlayer templateItem:_playerItem];
	
	_videoViewController = [AVPlayerViewController new];
	[_videoViewController setPlayer:_videoPlayer];
	[_videoViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_videoViewController setShowsPlaybackControls:NO];
	
	[_videoViewController.contentView.playbackContentContainerView setBackgroundColor:nil];
	
	[self addChildViewController:_videoViewController];
	[self.view addSubview:_videoViewController.view];
	[_videoViewController didMoveToParentViewController:self];
	
	[NSLayoutConstraint activateConstraints:@[
		[_videoViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
		[_videoViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[_videoViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
		[_videoViewController.view.heightAnchor constraintEqualToConstant:MIN(400, CGRectGetWidth(_videoViewController.view.bounds) * (mediaSize.height / mediaSize.width))]
	]];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	if (_videoViewController) {
		[self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint* constraint, NSUInteger index, BOOL* stop) {
			if (constraint.firstItem == self.scrollView && constraint.secondAnchor == self.view.safeAreaLayoutGuide.topAnchor) {
				[constraint setConstant:(CGRectGetHeight(_videoViewController.view.bounds) + 17)];
				*stop = YES;
			}
		}];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_videoPlayer) {
		[_videoPlayer seekToTime:CMTimeMake(0, 1)];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_videoPlayer) {
		[_videoPlayer play];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (_videoPlayer) {
		[_videoPlayer pause];
		[_videoPlayer seekToTime:CMTimeMake(0, 1)];
	}
}

@end