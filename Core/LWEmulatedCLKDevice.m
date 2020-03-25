//
// LWEmulatedCLKDevice.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWEmulatedCLKDevice.h"

@implementation LWEmulatedCLKDevice

+ (instancetype)deviceWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation forNRDevice:(NRDevice*)nrDevice {
	return [[self.class alloc] initWithJSONObjectRepresentation:jsonObjectRepresentation forNRDevice:nrDevice];
}

- (instancetype)initWithJSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation forNRDevice:(NRDevice*)nrDevice {
	if (self = [super init]) {
		[jsonObjectRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL* stop) {
			if ([key isEqualToString:@"_screenBounds"]) {
				[self setValue:[NSValue valueWithCGRect:CGRectFromString(value)] forKey:@"_screenBounds"];
			} else {
				[self setValue:value forKey:key];
			}
		}];
		
		[self setValue:nrDevice forKey:@"_nrDevice"];
	}
	
	return self;
}

@end