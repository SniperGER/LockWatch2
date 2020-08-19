//
// LWSiriComplicationDataSource.m
// LockWatch
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#include <substrate.h>
#include <objc/runtime.h>
#import <AssistantServices/AFPreferences.h>

#import "LWSiriComplicationDataSource.h"

extern NSString* NTKClockFaceLocalizedString(NSString* key, NSString* comment);

@interface AFApplicationInfo : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (assign, nonatomic) NSInteger pid;
- (id)initWithCoder:(_Nullable id)arg1;
@end

@interface SASRequestOptions : NSObject
@property (assign, nonatomic) CGFloat timestamp;
@property (assign, nonatomic) BOOL useAutomaticEndpointing;
@property (nonatomic, retain) NSArray *contextAppInfosForSiriViewController;
-(id)initWithRequestSource:(NSInteger)arg1 uiPresentationIdentifier:(id)arg2;
@end

@interface SBDismissOnlyAlertItem : NSObject
+ (void)activateAlertItem:(id)arg1;
- (id)initWithTitle:(id)arg1 body:(id)arg2;
@end

@interface SiriPresentationOptions : NSObject
@property (nonatomic, assign) BOOL wakeScreen;
@property (nonatomic, assign) BOOL hideOtherWindowsDuringAppearance;
@end

@interface SiriPresentationSpringBoardMainScreenViewController : UIViewController
- (void)presentationRequestedWithPresentationOptions:(id)arg1 requestOptions:(id)arg2;
@end

@interface SBAssistantController : NSObject {
	SiriPresentationSpringBoardMainScreenViewController* _mainScreenSiriPresentation;
}

+ (BOOL)isAssistantVisible;
+ (BOOL)isVisible;
+ (id)sharedInstance;
- (BOOL)handleSiriButtonDownEventFromSource:(NSInteger)arg1 activationEvent:(NSInteger)arg2;
- (void)handleSiriButtonUpEventFromSource:(NSInteger)arg1;
- (void)dismissPluginForEvent:(NSInteger)arg1;
- (void)dismissAssistantViewIfNecessary;
@end



@implementation LWSiriComplicationDataSource

- (instancetype)initWithComplication:(NTKComplication*)complication family:(long long)family forDevice:(CLKDevice*)device {
	if (self = [super initWithComplication:complication family:family forDevice:device]) {
		_siriEnabled = [[NSClassFromString(@"AFPreferences") sharedPreferences] assistantIsEnabled];
		
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(siriPreferencesChanged) name:@"AFPreferencesDidChangeNotification" object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:@"AFPreferencesDidChangeNotification" object:nil];
}

#pragma mark - Instance Methods

- (void)_invalidate {
	[self.delegate invalidateEntries];
}

- (void)_showSiriDisabledDialog {
	// UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NTKClockFaceLocalizedString(@"SIRI_DISABLED_ALERT_HEADER", @"Siri Not Enabled")
	// 																		 message:NTKClockFaceLocalizedString(@"SIRI_DISABLED_ALERT_MESSAGE", @"Please enable Siri on your iPhone.")
	// 																  preferredStyle:UIAlertControllerStyleAlert];
	// [alertController addAction:[UIAlertAction actionWithTitle:NTKClockFaceLocalizedString(@"SIRI_DISABLED_ALERT_BUTTON_TITLE", @"Dismiss") style:UIAlertActionStyleDefault handler:nil]];
	
	// [UIApplication.sharedApplication.windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow* window, NSUInteger index, BOOL* stop) {
	// 	if ([window isKindOfClass:NSClassFromString(@"SBCoverSheetWindow")]) {
	// 		[window.rootViewController presentViewController:alertController animated:YES completion:nil];
	// 		*stop = YES;
	// 	}
	// }];
	
	SBDismissOnlyAlertItem* alertItem = [[NSClassFromString(@"SBDismissOnlyAlertItem") alloc] initWithTitle:NTKClockFaceLocalizedString(@"SIRI_DISABLED_ALERT_HEADER", @"Siri Not Enabled") body:NTKClockFaceLocalizedString(@"SIRI_DISABLED_ALERT_MESSAGE", @"Please enable Siri on your iPhone.")];
	[objc_getClass("SBDismissOnlyAlertItem") activateAlertItem:alertItem];
}

- (void)siriPreferencesChanged {
	_siriEnabled = [[NSClassFromString(@"AFPreferences") sharedPreferences] assistantIsEnabled];
	
	[self _invalidate];
}

#pragma mark - NTKComplicationDataSource

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	CLKComplicationTemplateModularSmallSimpleImage* template = [CLKComplicationTemplateModularSmallSimpleImage new];
	CLKImageProvider* imageProvider = [CLKImageProvider imageProviderWithImageViewCreationHandler:^UIView* () {
		return [[NTKStaticSiriAnimationView alloc] initWithFrame:CGRectZero forDevice:[CLKDevice currentDevice]];
	}];
	
	[template setImageProvider:imageProvider];
	return template;
}

- (void)didTouchUpInsideView:(id)arg1 {
	if (!_siriEnabled) {
		/// TODO: Display message
		[self _showSiriDisabledDialog];
		return;
	}
	
	// This portion of code is proudly presented by DGh0st's DVirtualHome!
	// https://github.com/DGh0st/DVirtualHome
	
	SBAssistantController* assistantController = [NSClassFromString(@"SBAssistantController") sharedInstance];
	if ([objc_getClass("SBAssistantController") respondsToSelector:@selector(isAssistantVisible)]) {
		if (![objc_getClass("SBAssistantController") isAssistantVisible]) {
			[assistantController handleSiriButtonDownEventFromSource:1 activationEvent:1];
			[assistantController handleSiriButtonUpEventFromSource:1];
		}
	} else if ([objc_getClass("SBAssistantController") respondsToSelector:@selector(isVisible)]) {
		if (![objc_getClass("SBAssistantController") isVisible]) {
			SiriPresentationSpringBoardMainScreenViewController* presentation = (SiriPresentationSpringBoardMainScreenViewController*)[assistantController valueForKey:@"_mainScreenSiriPresentation"];

			SiriPresentationOptions* presentationOptions = [[NSClassFromString(@"SiriPresentationOptions") alloc] init];
			[presentationOptions setWakeScreen:YES];
			[presentationOptions setHideOtherWindowsDuringAppearance:NO];

			SASRequestOptions* requestOptions = [[NSClassFromString(@"SASRequestOptions") alloc] initWithRequestSource:1 uiPresentationIdentifier:@"com.apple.siri.Siriland"];
			[requestOptions setUseAutomaticEndpointing:YES];

			[presentation presentationRequestedWithPresentationOptions:presentationOptions requestOptions:requestOptions];
		}
	}
}

@end