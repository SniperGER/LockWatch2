//
// FSVLOBBaseSetupControllerInterface.h
// LockWatch2
//
// Created by janikschmidt on 7/12/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBFlowItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class OBButtonTray, OBTrayButton;
@protocol FSVLOBBaseSetupControllerInterface <NSObject>

@optional
- (instancetype)initWithTitle:(NSString*)title;
- (instancetype)initWithTitle:(NSString*)title detailText:(NSString*)detailText icon:(UIImage*)icon;
- (instancetype)initWithTitle:(NSString*)title detailText:(NSString*)detailText symbolName:(NSString*)symbolName;

- (void)addBulletedListItemWithDescription:(NSString*)description image:(UIImage*)image;
- (void)addBulletedListItemWithTitle:(NSString*)title description:(NSString*)description;
- (void)addBulletedListItemWithTitle:(NSString*)title description:(NSString*)description image:(UIImage*)image;

- (void)addSectionWithHeader:(NSString*)header content:(NSString*)content;

- (OBButtonTray*)buttonTray;

- (void)willMoveToFlowItem:(NSString*)itemIdentifier animated:(BOOL)animated;
- (void)didMoveToFlowItem:(NSString*)itemIdentifier animated:(BOOL)animated;
- (void)setupWillDismissWithCompletionState:(BOOL)completed;
- (void)setupDidDismissWithCompletionState:(BOOL)completed;

@required
@property (nonatomic) id <FSVLOBFlowItemDelegate> flowItemDelegate;
@property (nonatomic) NSDictionary* flowItemDefinition;
@property (nonatomic) OBTrayButton* primaryTrayButton;
@property (nonatomic) OBTrayButton* secondaryTrayButton;

- (void)buttonTapped:(OBTrayButton*)button;

- (NSString*)nextFlowItem;

@end

NS_ASSUME_NONNULL_END