#import <NanoTimeKitCompanion/NTKFaceCollection.h>

@interface LWPersistentFaceCollection : NTKFaceCollection

- (id)initWithCollectionIdentifier:(NSString*)identifier deviceUUID:(NSUUID*)uuid JSONObjectRepresentation:(NSDictionary*)jsonRepresentation;
- (NSDictionary*)JSONObjectRepresentation;

@end