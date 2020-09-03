#import "NTKFaceStyle.h"

@class CLKDevice;
@protocol LWCustomFaceInterface <NSObject>

@required
+ (BOOL)acceptsDevice:(CLKDevice*)device;
+ (Class)faceViewClass;
+ (NSUUID*)uuid;
- (NSString*)author;
- (NSString*)faceDescription;
- (NSString*)name;

@end