#import "LWEmulatedNRDevice.h"

@implementation LWEmulatedNRDevice

- (id)initWithJSONRepresentation:(NSDictionary*)jsonRepresentation pairingID:(NSUUID*)pairingID {
	if (self = [super initWithRegistry:nil diff:nil pairingID:pairingID notify:NO]) {
		_deviceData = [jsonRepresentation mutableCopy];
		
		[_deviceData enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL* stop) {
			if ([key isEqualToString:@"screenSize"]) {
				[_deviceData setObject:[NSValue valueWithCGSize:CGSizeFromString(value)] forKey:key];
			}
		}];
		
		_deviceData[@"name"] = @"LockWatch Emulated Device";
		_deviceData[@"pairingID"] = [pairingID UUIDString];
		
		[self setOldPropertiesForChangeNotifications:_deviceData];
	}
	
	return self;
}

- (id)description {
	return [NSString stringWithFormat:@"NRDevice<LWEmulatedNRDevice>: class=\"%@\" hwModelStr=\"%@\" name=\"%@\" mainScreenClass=\"%@\" mainScreenHeight=\"%@\" mainScreenWidth=\"%@\" modelNumber=\"%@\" pairingID=\"%@\" productType=\"%@\" screenScale=\"%@\" screenSize=\"%@\"",
		[self valueForProperty:@"class"],
		[self valueForProperty:@"hwModelStr"],
		[self valueForProperty:@"name"],
		[self valueForProperty:@"mainScreenClass"],
		[self valueForProperty:@"mainScreenHeight"],
		[self valueForProperty:@"mainScreenWidth"],
		[self valueForProperty:@"modelNumber"],
		[self valueForProperty:@"pairingID"],
		[self valueForProperty:@"productType"],
		[self valueForProperty:@"screenScale"],
		[self valueForProperty:@"screenSize"]
	];
}

- (id)valueForProperty:(id)property {
	if (_deviceData[property]) {
		return _deviceData[property];
	}
	
	return nil;
}

- (BOOL)supportsCapability:(id)capability {
	return YES;
}

@end