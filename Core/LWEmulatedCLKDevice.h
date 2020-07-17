//
// LWEmulatedCLKDevice.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoRegistry/NRDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLKDevice (ScreenBounds)
- (CGRect)actualScreenBounds;
- (CGFloat)actualScreenCornerRadius;
@end

@interface LWEmulatedCLKDevice : CLKDevice

@property (nonatomic) CLKDevice* physicalDevice;

+ (instancetype)deviceWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation forNRDevice:(NRDevice*)nrDevice;
- (instancetype)initWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation forNRDevice:(NRDevice*)nrDevice;

@end

NS_ASSUME_NONNULL_END