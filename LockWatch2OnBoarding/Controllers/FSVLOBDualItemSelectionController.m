//
// FSVLOBDualItemSelectionController.m
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBDualItemSelectionController.h"

extern NSBundle* LWOLocalizableBundle();
extern NSString* LWOLocalizedString();

@implementation FSVLOBDualItemSelectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	_mainContainer = [[UIStackView alloc] initWithFrame:CGRectZero];
	[_mainContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_mainContainer setAlignment:UIStackViewAlignmentTop];
	[_mainContainer setDistribution:UIStackViewDistributionFillEqually];
	[self.contentView addSubview:_mainContainer];
	
	if (_flowItemDefinition[@"Items"][@"LeftItem"]) {
		UIImage* leftContainerImage = [UIImage imageNamed:_flowItemDefinition[@"Items"][@"LeftItem"][@"Image"] inBundle:LWOLocalizableBundle() compatibleWithTraitCollection:nil];
		if (!leftContainerImage)  {
			leftContainerImage = [UIImage imageWithContentsOfFile:_flowItemDefinition[@"Items"][@"LeftItem"][@"Image"]];
		}
		
		_leftContainer = [[FSVLOBSelectionItemView alloc] initWithTitle:LWOLocalizedString(_flowItemDefinition[@"Items"][@"LeftItem"][@"Title"], nil) image:leftContainerImage value:_flowItemDefinition[@"Items"][@"LeftItem"][@"Value"]];
		[_mainContainer addArrangedSubview:_leftContainer];
		
		_leftTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
		[_leftContainer addGestureRecognizer:_leftTapRecognizer];
	}
	
	if (_flowItemDefinition[@"Items"][@"RightItem"]) {
		UIImage* rightContainerImage = [UIImage imageNamed:_flowItemDefinition[@"Items"][@"RightItem"][@"Image"] inBundle:LWOLocalizableBundle() compatibleWithTraitCollection:nil];
		if (!rightContainerImage)  {
			rightContainerImage = [UIImage imageWithContentsOfFile:_flowItemDefinition[@"Items"][@"RightItem"][@"Image"]];
		}
		
		_rightContainer = [[FSVLOBSelectionItemView alloc] initWithTitle:LWOLocalizedString(_flowItemDefinition[@"Items"][@"RightItem"][@"Title"], nil) image:rightContainerImage value:_flowItemDefinition[@"Items"][@"RightItem"][@"Value"]];
		[_mainContainer addArrangedSubview:_rightContainer];
		
		_rightTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
		[_rightContainer addGestureRecognizer:_rightTapRecognizer];
	}
	
	[NSLayoutConstraint activateConstraints:@[
		[_mainContainer.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:17.0],
		[_mainContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
		[_mainContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
		[self.contentView.bottomAnchor constraintEqualToAnchor:_mainContainer.bottomAnchor]
	]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_leftContainer.isSelected || _rightContainer.isSelected) {
		[_primaryTrayButton setEnabled:YES];
		[_primaryTrayButton setUserInteractionEnabled:YES];
	} else {	
		[_primaryTrayButton setEnabled:NO];
		[_primaryTrayButton setUserInteractionEnabled:NO];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[_leftContainer setSelected:NO];
		[_rightContainer setSelected:NO];
		
		[_primaryTrayButton setEnabled:NO];
		[_primaryTrayButton setUserInteractionEnabled:NO];
	}
}

#pragma mark - Instance Methods

- (void)didSelectSegment:(NSUInteger)segment {
	[_primaryTrayButton setEnabled:YES];
	[_primaryTrayButton setUserInteractionEnabled:YES];
}

- (void)selectSegment:(NSUInteger)segment {
	if (segment == 0) {
		[_leftContainer setSelected:YES];
		[_rightContainer setSelected:NO];
	} else if (segment == 1) {
		[_leftContainer setSelected:NO];
		[_rightContainer setSelected:YES];
	}
	
	[self didSelectSegment:segment];
}

- (void)itemTapped:(UIGestureRecognizer*)sender {
	if (sender.state != UIGestureRecognizerStateEnded) return;
	
	if (sender.view == _leftContainer) {
		[self selectSegment:0];
	} else if (sender.view == _rightContainer) {
		[self selectSegment:1];
	}
}

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {
	if (button == _primaryTrayButton) {
		[self.flowItemDelegate moveToFlowItem:[self nextFlowItem] animated:YES];
	}
}

- (NSString*)nextFlowItem {
	if (_leftContainer.isSelected && _flowItemDefinition[@"Items"][@"LeftItem"][@"NextFlowItem"]) {
		return _flowItemDefinition[@"Items"][@"LeftItem"][@"NextFlowItem"];
	} else if (_rightContainer.isSelected && _flowItemDefinition[@"Items"][@"RightItem"][@"NextFlowItem"]) {
		return _flowItemDefinition[@"Items"][@"RightItem"][@"NextFlowItem"];
	}
	
	return _flowItemDefinition[@"NextFlowItem"];
}

@end