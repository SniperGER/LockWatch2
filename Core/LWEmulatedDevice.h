#import <ClockKit/CLKDevice.h>

@interface CLKDevice (ScreenBounds)
- (CGRect)actualScreenBounds;
@end

@interface LWEmulatedDevice : CLKDevice
- (id)initWithJSONRepresentation:(NSDictionary*)jsonRepresentation nrDevice:(NRDevice*)nrDevice;
@end