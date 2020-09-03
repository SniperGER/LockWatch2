//
// LWPersistentFaceCollection.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKDevice.h>
#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "NTKFaceStyle.h"

NS_ASSUME_NONNULL_BEGIN

extern void *NTKAllAvailableFaceStyles(void *device);
extern void *NTKDefaultLibraryFaceStyles(void *device);
extern int NTKDefaultLibrarySelectedFace(void *device);



@interface NTKFaceCollection (JSON)
- (NSDictionary*)JSONObjectRepresentation;
@end

@interface LWPersistentFaceCollection : NTKFaceCollection

+ (NSArray*)allAvailableFaceStylesForDevice:(CLKDevice*)device;
+ (NSArray*)defaultLibraryFaceStylesForDevice:(CLKDevice*)device;
+ (int)defaultLibrarySelectedFaceForDevice:(CLKDevice*)device;
+ (instancetype)defaultAddableFaceCollectionForDevice:(CLKDevice*)device;
+ (instancetype)defaultLibraryFaceCollectionForDevice:(CLKDevice*)device;
+ (instancetype)externalFaceCollectionForDevice:(CLKDevice*)device;
+ (instancetype)faceCollectionWithContentsOfFile:(NSString*)path collectionIdentifier:(NSString*)identifier forDevice:(CLKDevice*)device;
+ (BOOL)faceStyleIsRestricted:(NTKFaceStyle)style forDevice:(CLKDevice*)device;
- (instancetype)initWithCollectionIdentifier:(NSString*)identifier forDevice:(CLKDevice*)device faceStyles:(NSArray*)faceStyles selectedFaceIndex:(int)selectedFaceIndex;
- (instancetype)initWithCollectionIdentifier:(NSString*)identifier forDevice:(CLKDevice*)device JSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation;
- (void)addObserver:(id <NTKFaceCollectionObserver>)observer;
- (BOOL)hasLoaded;
- (void)notifyLoaded;
- (void)reset;
- (void)resumeUpdatesFromDaemon;
- (void)suspendUpdatesFromDaemon;
- (BOOL)synchronize;
- (BOOL)writeToFile:(NSString*)path;

@end

NS_ASSUME_NONNULL_END