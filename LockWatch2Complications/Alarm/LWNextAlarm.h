//
// LWNextAlarm.h
// LockWatch
//
// Created by janikschmidt on 8/14/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Foundation/Foundation.h>
#import <MobileTimer/MTAlarm.h>
#import <MobileTimer/MTTrigger.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWNextAlarm : NSObject

@property (nonatomic) MTTrigger* trigger;
@property (nonatomic) MTAlarm* alarm;

@end

NS_ASSUME_NONNULL_END