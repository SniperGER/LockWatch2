//
// LWPersistentFaceCollection.m
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#define kLWAddableFacesCollectionIdentifier @"AddableFaces"
#define kLWExternalFacesCollectionIdentifier @"ExternalFaces"
#define kLWLibraryFacesCollectionIdentifier @"LibraryFaces"

#import <dlfcn.h>
#import <objc/runtime.h>

#import "LWCustomFaceInterface.h"
#import "LWPersistentFaceCollection.h"

extern NSString* NTKLocalizedNameForFaceStyle(NSUInteger style);



@implementation NSBundle (ClassList)
- (NSArray<Class>*)classList {
	if (![self executablePath]) return nil;
	
	dlopen([[self executablePath] UTF8String], RTLD_NOW);
	NSMutableArray* classList = [NSMutableArray array];
		
	unsigned int classCount = 0;
	const char** classes = objc_copyClassNamesForImage([[self executablePath] UTF8String], &classCount);
	for (int i=0; i < classCount; i++) {
		NSString* className = [NSString stringWithUTF8String:classes[i]];
		[classList addObject:NSClassFromString(className)];
	}

    return classList;
}
@end



@implementation NTKFaceCollection (JSON)
- (NSDictionary*)JSONObjectRepresentation {
	NSMutableArray* faceJSON = [NSMutableArray array];
	
	[self enumerateFacesWithIndexesUsingBlock:^(NTKFace* face, NSUInteger index, BOOL* stop) {
		[faceJSON insertObject:face.JSONObjectRepresentation atIndex:index];
	}];
	
	return @{
		@"faces": faceJSON,
		@"selectedFaceIndex": @(self.selectedFaceIndex)
	};
}
@end

@implementation LWPersistentFaceCollection

+ (NSArray*)allAvailableFaceStylesForDevice:(CLKDevice*)device {
	NSArray* faceStyles = (__bridge NSArray*)NTKAllAvailableFaceStyles((__bridge void*)device);
	
	faceStyles = [faceStyles sortedArrayUsingComparator:^NSComparisonResult(NSNumber* number1, NSNumber* number2) {
        return [NTKLocalizedNameForFaceStyle([number1 integerValue]) compare:NTKLocalizedNameForFaceStyle([number2 integerValue])];
    }];
	
	return faceStyles;
}

+ (NSArray*)defaultLibraryFaceStylesForDevice:(CLKDevice*)device {
	return (__bridge NSArray*)NTKDefaultLibraryFaceStyles((__bridge void*)device);
}

+ (int)defaultLibrarySelectedFaceForDevice:(CLKDevice*)device {
	return NTKDefaultLibrarySelectedFace((__bridge void*)device);
}



+ (instancetype)defaultAddableFaceCollectionForDevice:(CLKDevice*)device {
	if (!device) return nil;
	
	NSArray* faceStyles = [self.class allAvailableFaceStylesForDevice:device];
	
	return [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:kLWAddableFacesCollectionIdentifier forDevice:device faceStyles:faceStyles selectedFaceIndex:0];
}

+ (instancetype)defaultLibraryFaceCollectionForDevice:(CLKDevice*)device {
	if (!device) return nil;
	
	NSArray* faceStyles = [self.class defaultLibraryFaceStylesForDevice:device];
	int selectedFaceIndex = [self.class defaultLibrarySelectedFaceForDevice:device];
	
	return [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:kLWLibraryFacesCollectionIdentifier forDevice:device faceStyles:faceStyles selectedFaceIndex:selectedFaceIndex];
}

+ (instancetype)externalFaceCollectionForDevice:(CLKDevice*)device {
	if (!device) return nil;
	
	NSMutableArray* classList = [NSMutableArray array];
	
	[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:THIRD_PARTY_FACES_PATH error:nil] enumerateObjectsUsingBlock:^(NSString* entry, NSUInteger index, BOOL* stop) {
		NSBundle* bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", THIRD_PARTY_FACES_PATH, entry]];
		if (!bundle || !bundle.executablePath) return;
		
		[[bundle classList] enumerateObjectsUsingBlock:^(Class class, NSUInteger index, BOOL* stop) {
			if ([class isSubclassOfClass:[NTKFace class]] && 
				[class conformsToProtocol:@protocol(LWCustomFaceInterface)] &&
				[class acceptsDevice:device]) {
				[classList addObject:class];
			}
		}];
	}];
	
	classList = [[classList sortedArrayUsingComparator:^NSComparisonResult(Class class1, Class class2) {
        NTKFace* face1 = [class1 new];
        NTKFace* face2 = [class2 new];
		
		return [[face1 name] compare:[face2 name]];
    }] mutableCopy];
	
	return [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:kLWExternalFacesCollectionIdentifier forDevice:device externalFaceClasses:classList];
}

+ (instancetype)faceCollectionWithContentsOfFile:(NSString*)path
							collectionIdentifier:(NSString*)identifier
									   forDevice:(CLKDevice*)device {
	if (!device) return nil;
	
	NSDictionary* faceJSON = [NSDictionary dictionaryWithContentsOfFile:path];
	if (!faceJSON) return nil;
	
	LWPersistentFaceCollection* collection = [[LWPersistentFaceCollection alloc] initWithCollectionIdentifier:identifier forDevice:device JSONObjectRepresentation:faceJSON];
	
	return collection;
}

+ (BOOL)faceStyleIsRestricted:(NTKFaceStyle)style
					forDevice:(CLKDevice*)device {
	BOOL restricted = NO;
	
	// Disabled faces for Series 3
	if (device.sizeClass == 1) {
		switch (style) {
			case NTKFaceStyleWhistlerDigital:
			case NTKFaceStyleWhistlerAnalog:
			case NTKFaceStyleWhistlerSubdials:
			case NTKFaceStyleOlympus:
			case NTKFaceStyleSidereal:
			case NTKFaceStyleCalifornia:
			case NTKFaceStyleBlackcomb:
			case NTKFaceStyleSpectrumAnalog:
			case NTKFaceStyleWhitetank:
				restricted = YES;
				break;
			default:
				break;
		}
	}
	
	// Disabled faces for Series 5
	if (device.sizeClass == 2) {
		switch (style) {
			default:
				break;
		}
	}
	
	// Globally disabled faces
	switch (style) {
		case NTKFaceStyleKaleidoscope:
			restricted = TARGET_OS_SIMULATOR;
			break;
		default:
			break;
	}
	
	return restricted;
}



- (instancetype)initWithCollectionIdentifier:(NSString*)identifier
								   forDevice:(CLKDevice*)device
								  faceStyles:(NSArray*)faceStyles
						   selectedFaceIndex:(int)selectedFaceIndex {
	if (self = [super initWithCollectionIdentifier:identifier deviceUUID:device.nrDeviceUUID]) {
		[faceStyles enumerateObjectsUsingBlock:^(NSNumber* faceStyle, NSUInteger index, BOOL* stop) {
			if (![self.class faceStyleIsRestricted:faceStyle.integerValue forDevice:device]) {
				NTKFace* face = [NTKFace defaultFaceOfStyle:faceStyle.integerValue forDevice:device];
				
				if (face) {
					[self appendFace:face suppressingCallbackToObserver:nil];
				}
			}
		}];
		[self setSelectedFaceIndex:MIN(MAX(selectedFaceIndex, 0), self.numberOfFaces - 1) suppressingCallbackToObserver:nil];
	}
	
	return self;
}

- (instancetype)initWithCollectionIdentifier:(NSString*)identifier
								   forDevice:(CLKDevice*)device
					JSONObjectRepresentation:(NSDictionary*)jsonObjectRepresentation {
	if (self = [super initWithCollectionIdentifier:identifier deviceUUID:device.nrDeviceUUID]) {
		[jsonObjectRepresentation[@"faces"] enumerateObjectsUsingBlock:^(NSDictionary* faceJSON, NSUInteger index, BOOL* stop) {
			NTKFace* face = [NTKFace faceWithJSONObjectRepresentation:faceJSON forDevice:device];
			
			if (face && ![self.class faceStyleIsRestricted:face.faceStyle forDevice:device]) {
				[self appendFace:face suppressingCallbackToObserver:nil];
			}
		}];
		
		NSInteger selectedFaceIndex = [jsonObjectRepresentation[@"selectedFaceIndex"] integerValue];
		[self setSelectedFaceIndex:MIN(MAX(selectedFaceIndex, 0), self.numberOfFaces - 1) suppressingCallbackToObserver:nil];
	}
	
	return self;
}

- (instancetype)initWithCollectionIdentifier:(NSString*)identifier
								   forDevice:(CLKDevice*)device
						 externalFaceClasses:(NSArray<Class>*)classList {
	if (self = [super initWithCollectionIdentifier:identifier deviceUUID:device.nrDeviceUUID]) {
		[classList enumerateObjectsUsingBlock:^(Class faceClass, NSUInteger index, BOOL* stop) {
			NTKFace* face = [[faceClass alloc] _initWithFaceStyle:0x100 forDevice:device];
			
			if (face) {
				[self appendFace:face suppressingCallbackToObserver:nil];
			}
		}];
	}
	
	return self;
}

#pragma mark - Instance Methods

- (void)addObserver:(id <NTKFaceCollectionObserver>)observer {
	[super addObserver:observer];
	
	if (self.hasLoaded && [observer respondsToSelector:@selector(faceCollectionDidLoad:)]) {
		[observer faceCollectionDidLoad:self];
	}
}

- (BOOL)hasLoaded {
	return YES;
}

- (void)notifyLoaded {
	NSArray<id <NTKFaceCollectionObserver>>* observers = ((NSHashTable*)self.observers).allObjects;
	[observers enumerateObjectsUsingBlock:^(id <NTKFaceCollectionObserver> observer, NSUInteger index, BOOL* stop) {
		if ([observer respondsToSelector:@selector(faceCollectionDidLoad:)]) {
			[observer faceCollectionDidLoad:self];
		}
	}];
}

- (void)reset {
	NSInteger numberOfFaces = self.numberOfFaces;
	for (int i = 0; i < numberOfFaces; i++) {
		[self removeFace:[self faceAtIndex:0] suppressingCallbackToObserver:nil];
	}
	
	CLKDevice* device = [CLKDevice currentDevice];
	NSArray* faceStyles = @[];
	NSInteger selectedFaceIndex = 0;
	
	if ([self.collectionIdentifier isEqualToString:kLWLibraryFacesCollectionIdentifier]) {
		faceStyles = [self.class defaultLibraryFaceStylesForDevice:device];
		selectedFaceIndex = [self.class defaultLibrarySelectedFaceForDevice:device];
	} else if ([self.collectionIdentifier isEqualToString:kLWAddableFacesCollectionIdentifier]) {
		faceStyles = [self.class allAvailableFaceStylesForDevice:device];
	}
	
	[faceStyles enumerateObjectsUsingBlock:^(NSNumber* faceStyle, NSUInteger index, BOOL* stop) {
		if (![self.class faceStyleIsRestricted:faceStyle.integerValue forDevice:device]) {
			NTKFace* face = [NTKFace defaultFaceOfStyle:faceStyle.integerValue forDevice:device];
			
			if (face) {
				[self appendFace:face suppressingCallbackToObserver:nil];
			}
		}
	}];
	[self setSelectedFaceIndex:selectedFaceIndex suppressingCallbackToObserver:nil];
}

- (void)resumeUpdatesFromDaemon {}

- (void)suspendUpdatesFromDaemon {}


- (BOOL)synchronize {
	if ([self.collectionIdentifier isEqualToString:kLWAddableFacesCollectionIdentifier]) return NO;
	
	return [self writeToFile:LIBRARY_PATH];
}

- (BOOL)writeToFile:(NSString*)path {
	return [[self JSONObjectRepresentation] writeToFile:path atomically:YES];
}

@end
