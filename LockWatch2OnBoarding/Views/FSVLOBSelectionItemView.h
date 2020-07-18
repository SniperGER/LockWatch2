//
// FSVLOBSelectionItemView.h
// LockWatch
//
// Created by janikschmidt on 7/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSVLOBSelectionItemView : UIView {
	UIImageView* _imageView;
	UILabel* _textLabel;
	UIImageView* _accessoryView;
}

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) id value;

- (instancetype)initWithTitle:(NSString*)title image:(UIImage*)image value:(id)value;

@end

NS_ASSUME_NONNULL_END