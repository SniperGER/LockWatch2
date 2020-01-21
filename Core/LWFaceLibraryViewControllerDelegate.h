@class LWFaceLibraryViewController, NTKFace, NTKFaceViewController;

@protocol LWFaceLibraryViewControllerDelegate <NSObject>

- (void)faceLibraryViewControllerDidCompleteSelection:(LWFaceLibraryViewController*)faceLibraryViewController;
- (void)faceLibraryViewControllerWillCompleteSelection:(LWFaceLibraryViewController*)faceLibraryViewController;
- (NTKFaceViewController*)faceLibraryViewController:(LWFaceLibraryViewController*)faceLibraryViewController newViewControllerForFace:(NTKFace*)face configuration:(void (^)(NTKFaceViewController*))configuration;

@end