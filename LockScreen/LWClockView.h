//
//  LWClockView.h
//  LockWatch2
//
//  Created by janikschmidt on 1/13/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWClockViewDelegate;

@interface LWClockView : UIView {
	UILongPressGestureRecognizer* _longPressGesture;
}

@property (nonatomic) id <LWClockViewDelegate> delegate;
@property (nonatomic) BOOL orbZoomEnabled;

@end