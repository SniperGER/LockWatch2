//
// FSVLOBMediaController.h
// LockWatch
//
// Created by janikschmidt on 7/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

#import "FSVLOBWelcomeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSVLOBMediaController : FSVLOBWelcomeController {
	AVPlayerItem* _playerItem;
	AVQueuePlayer* _videoPlayer;
	AVPlayerLooper* _playerLooper;
	AVPlayerViewController* _videoViewController;
	
	NSLayoutConstraint* _headerViewTopConstraint;
}

@end

NS_ASSUME_NONNULL_END