#import "LWPersistentFaceCollection.h"

@implementation LWPersistentFaceCollection

- (id)initWithCollectionIdentifier:(NSString*)identifier deviceUUID:(NSUUID*)uuid JSONObjectRepresentation:(NSDictionary*)jsonRepresentation {
	if (self = [super initWithCollectionIdentifier:identifier deviceUUID:uuid]) {
		
	}
	
	return self;
}

- (NSDictionary*)JSONObjectRepresentation {
	return @{
		@"collectionIdentifier": self.collectionIdentifier,
		@"debugName": self.debugName,
		@"deviceUUID": self.deviceUUID,
		@"facesByUUID": self.facesByUUID,
		@"orderedUUIDs": self.orderedUUIDs,
		@"selectedUUID": self.selectedUUID
	};
}

@end