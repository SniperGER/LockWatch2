#import <NanoRegistry/NRDevice.h>

@interface LWEmulatedNRDevice : NRDevice {
	NSMutableDictionary* _deviceData;
}

- (id)initWithJSONRepresentation:(NSDictionary*)jsonRepresentation pairingID:(NSUUID*)pairingID;

@end