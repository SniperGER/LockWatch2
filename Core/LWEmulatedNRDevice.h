//
// LWEmulatedNRDevice.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <NanoRegistry/NRDevice.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NRDeviceMainScreenClass) {
	NRDeviceMainScreenClass42mm = 12,
	NRDeviceMainScreenClass38mm = 13,
	NRDeviceMainScreenClass40mm = 16,
	NRDeviceMainScreenClass44mm = 17
};

@interface LWEmulatedNRDevice : NRDevice {
	NSMutableDictionary* _deviceData;
}

+ (instancetype)deviceWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation pairingID:(NSUUID*)pairingID;
- (instancetype)initWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation pairingID:(NSUUID*)pairingID;
- (id)description;
- (BOOL)supportsCapability:(id)capability;
- (id)valueForProperty:(id)property;

@end

NS_ASSUME_NONNULL_END