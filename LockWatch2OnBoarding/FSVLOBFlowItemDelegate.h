//
// FSVLOBFlowItemDelegate.h
// LockWatch
//
// Created by janikschmidt on 7/5/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FSVLOBFlowItemDelegate <NSObject>

@required
- (void)moveToFlowItem:(NSString*)itemIdentifier animated:(BOOL)animated;
- (void)resetFlowAnimated:(BOOL)animated;
- (void)dismissWithSetupCompletionState:(BOOL)completed;

@end

NS_ASSUME_NONNULL_END