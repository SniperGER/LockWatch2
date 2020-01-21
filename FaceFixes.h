#import <ClockKit/CLKDevice.h>
#import <NanoRegistry/NRDevice.h>
#import <NanoTimeKitCompanion/NTKFace.h>



@interface ARUIRingsView : UIView
@end

@interface CALayer (Private)
 - (BOOL)hasSuperviewOfClass:(Class)_class;
@end

@interface CLKVideoPlayerView : UIView
@end

@interface NTKAnalogFaceView : UIView
@property (nonatomic, retain) UIView *contentView;
@end

@interface NTKCompanionFaceViewController : UIViewController
// %property
@property (nonatomic, strong) UIVisualEffectView* effectView;

- (NTKFace*)face;
- (UIView*)faceView;
@end

@interface NTKExplorerDialView : UIView
@end

@interface NTKRoundedCornerOverlayView : UIView
@end

@interface NTKSiderealDialBackgroundView : UIView
@end