#import "LWEmulatedDevice.h"

@implementation LWEmulatedDevice

- (id)initWithJSONRepresentation:(NSDictionary*)jsonRepresentation nrDevice:(NRDevice*)nrDevice {
	if (self = [super init]) {
		[jsonRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL* stop) {
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