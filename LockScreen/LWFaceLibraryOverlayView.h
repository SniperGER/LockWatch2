//
//  LWFaceLibraryOverlayView.h
//  LockWatch2
//
//  Created by janikschmidt on 1/19/2020.
//  Copyright © 2020 Team FESTIVAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLKDevice;

@interface LWFaceLibraryOverlayView : UIScrollView <UIScrollViewDelegate> {
	CLKDevice* _device;
	NSMutableDictionary* _titleLabels;
	
	CGFloat _previousScrollPosition;
}

@property (nonatomic) CGFloat distanceBetweenLabels;
@property (nonatomic, readonly) UIButton* cancelButton;
@property (nonatomic, readonly) UIButton* editButton;

- (id)initForDevice:(CLKDevice*)device;
- (void)addTitle:(NSString*)title forIndex:(NSInteger)index;
- (UILabel*)labelAtIndex:(NSInteger)index;
- (UILabel*)newTitleLabel;
- (void)scrollToLabelAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setLabelOffset:(CGFloat)offset;
- (void)updateContentSize;

@end