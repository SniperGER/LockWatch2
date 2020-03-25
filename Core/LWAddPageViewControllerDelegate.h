//
// LWAddPageViewControllerDelegate.h
// LockWatch2
//
// Created by janikschmidt on 2/15/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

@class LWAddPageViewController, NTKFace, NTKFaceViewController;

@protocol LWAddPageViewControllerDelegate <NSObject>

- (void)addPageViewController:(LWAddPageViewController*)addPageViewController didSelectFace:(NTKFace*)face faceViewController:(NTKFaceViewController*)faceViewController;

@end