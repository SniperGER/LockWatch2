//
// FSVLOBSelectionItemView.m
// LockWatch
//
// Created by janikschmidt on 7/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBSelectionItemView.h"

@interface UIImage (Private)
- (void)_setContentInsets:(UIEdgeInsets)arg1;
@end

@implementation FSVLOBSelectionItemView

- (instancetype)initWithTitle:(NSString*)title image:(UIImage*)image value:(id)value {
	if (self = [super initWithFrame:CGRectZero]) {
		_value = value;
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		_imageView = [[UIImageView alloc] initWithImage:image];
		[_imageView setContentMode:UIViewContentModeCenter];
		[_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self addSubview:_imageView];
		
		_textLabel = [UILabel new];
		[_textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_textLabel setText:title];
		[_textLabel setNumberOfLines:0];
		[_textLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:_textLabel];
		
		_accessoryView = [[UIImageView alloc] initWithFrame:(CGRect){{ 0, 0 }, { 24, 24 }}];
		[_accessoryView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_accessoryView setTintColor:UIColor.systemOrangeColor];
		[_accessoryView.layer setCornerRadius:12];
		[_accessoryView.layer setBorderWidth:1];
		[_accessoryView.layer setBorderColor:[UIColor colorWithRed:0.557 green:0.557 blue:0.576 alpha:1.0].CGColor];
		[self addSubview:_accessoryView];
		
		if (image) {
			[NSLayoutConstraint activateConstraints:@[
				[_imageView.heightAnchor constraintEqualToConstant:MIN(image.size.height, image.size.width * (image.size.height / image.size.width))]
			]];
		}
		
		[NSLayoutConstraint activateConstraints:@[
			[_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24.0],
			[_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24.0],
			[_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[_textLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:22],
			[_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24.0],
			[_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24.0],
			[_accessoryView.topAnchor constraintEqualToAnchor:_textLabel.bottomAnchor constant:8],
			[_accessoryView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			[_accessoryView.widthAnchor constraintEqualToConstant:24],
			[_accessoryView.heightAnchor constraintEqualToConstant:24],
			[_accessoryView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]
		]];
		
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)setSelected:(BOOL)selected {
	_selected = selected;
	
	if (selected) {
		[_accessoryView.layer setBorderWidth:0];
		[_accessoryView setBackgroundColor:UIColor.whiteColor];
		
		UIImage* checkmarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge]];
		[checkmarkImage _setContentInsets:UIEdgeInsetsZero];
		[_accessoryView setImage:checkmarkImage];
	} else {
		[_accessoryView.layer setBorderWidth:1];
		[_accessoryView setImage:nil];
		[_accessoryView setBackgroundColor:nil];
	}
}

@end