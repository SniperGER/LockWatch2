//
// LWFaceLibraryViewControllerDelegate.h
// LockWatch2
//
// Created by janikschmidt on 1/27/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWFaceLibraryViewController, NTKFace, NTKFaceViewController;

@protocol LWFaceLibraryViewControllerDelegate <NSObject>

- (NTKFaceViewController*)faceLibraryViewController:(LWFaceLibraryViewController*)libraryViewController newViewControllerForFace:(NTKFace*)face configuration:(void (^)(NTKFaceViewController*))configuration;
- (void)faceLibraryViewControllerDidCompleteSelection:(LWFaceLibraryViewController*)libraryViewController;
- (void)faceLibraryViewControllerWillCompleteSelection:(LWFaceLibraryViewController*)libraryViewController;

@end