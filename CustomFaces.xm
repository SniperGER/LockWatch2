//
// CustomFaces.xm
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#include <substrate.h>

#import <NanoTimeKitCompanion/NanoTimeKitCompanion.h>

#import "Core/LWCustomFaceInterface.h"
#import "Core/LWPreferences.h"

%group SpringBoard
%hook NTKFace
+ (instancetype)faceWithJSONObjectRepresentation:(NSDictionary*)arg1 forDevice:(CLKDevice*)arg2 {
	if ([[arg1 objectForKeyedSubscript:@"face type"] isEqualToString:@"custom"]) {
		NTKFace<LWCustomFaceInterface>* face = [[NSClassFromString([arg1 objectForKeyedSubscript:@"class"]) alloc] _initWithFaceStyle:0x100 forDevice:arg2];
		
		if (face) {
			NTKFaceConfiguration* faceConfiguration = [[NTKFaceConfiguration alloc] initWithJSONDictionary:arg1 editModeMapping:face forDevice:arg2];
			[face _customizeWithJSONDescription:arg1];
			[face _applyConfiguration:faceConfiguration allowFailure:NO];
		}
		
		return face;
	}
	
	return %orig;
}

- (NSMutableDictionary*)JSONObjectRepresentation {
	NSMutableDictionary* r = %orig;
	
	if (self.faceStyle == 0x100) {
		[r setObject:@"custom" forKey:@"face type"];
		[r setObject:NSStringFromClass(self.class) forKey:@"class"];
		[r setObject:[[NSBundle bundleForClass:self.class] bundleIdentifier] forKey:@"bundle identifier"];
	}
	
	return r;
}
%end	/// %hook NTKFace

%hook NTKFaceViewController
- (void)loadView {
	if ([self.face.class conformsToProtocol:@protocol(LWCustomFaceInterface)]) {
		CLKDevice* device = [CLKDevice currentDevice];
		NTKFace<LWCustomFaceInterface>* face = (NTKFace<LWCustomFaceInterface>*)self.face;
		UIView* view = [UIView new];
		
		NTKFaceView* faceView = [[[face.class faceViewClass] alloc] initWithFaceStyle:[face faceStyle] forDevice:device clientIdentifier:nil];
		[faceView setDelegate:self];
		MSHookIvar<NTKFaceView*>(self, "_faceView") = faceView;
		
		[self _setFaceViewResourceDirectoryFromFace];
		[faceView populateFaceViewEditOptionsFromFace:face];
		[self _loadInitialComplicationVisibilityFromFace];

		[view setBounds:faceView.bounds];
		[view addSubview:faceView];
		[self setView:view];
	} else {
		%orig;
	}
}
%end	/// %hook NTKFaceViewController
%end	// %group SpringBoard



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [LWPreferences sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if (IN_SPRINGBOARD) {
				%init(SpringBoard);
			}
		}
	}
}