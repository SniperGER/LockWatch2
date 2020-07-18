//
// FSVLOBDualItemSelectionController.h
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <OnBoardingKit/OnBoardingKit.h>

#import "FSVLOBBaseSetupControllerInterface.h"
#import "FSVLOBFlowItemDelegate.h"
#import "Views/FSVLOBSelectionItemView.h"

NS_ASSUME_NONNULL_BEGIN

@class OBTrayButton;

@interface FSVLOBDualItemSelectionController : OBWelcomeController <FSVLOBBaseSetupControllerInterface> {
	UIStackView* _mainContainer;
	UITapGestureRecognizer* _leftTapRecognizer;
	UITapGestureRecognizer* _rightTapRecognizer;
}

@property (nonatomic) id <FSVLOBFlowItemDelegate> flowItemDelegate;
@property (nonatomic) NSDictionary* flowItemDefinition;
@property (nonatomic) OBTrayButton* primaryTrayButton;
@property (nonatomic) OBTrayButton* secondaryTrayButton;

@property (nonatomic) FSVLOBSelectionItemView* leftContainer;
@property (nonatomic) FSVLOBSelectionItemView* rightContainer;

@end

NS_ASSUME_NONNULL_END