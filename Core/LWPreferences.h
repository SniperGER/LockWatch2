//
// LWPreferences.h
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, LWComplicationContentType) {
/*  0 */	LWComplicationContentTypeNone,
/*  1 */	LWComplicationContentTypeTemplate,
/*  2 */	LWComplicationContentTypeDefault,
/*  3 */	LWComplicationContentTypeFinishedOnly,
};

@interface LWPreferences : NSObject {
	NSMutableDictionary* _defaults;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isEmulatingDevice;
@property (nonatomic) NSString* emulatedDeviceType;
@property (nonatomic) NSInteger backgroundType;
@property (nonatomic) BOOL batteryChargingViewHidden;
@property (nonatomic) LWComplicationContentType complicationContent;

@property (nonatomic) CGFloat horizontalOffsetPortrait;
@property (nonatomic) CGFloat verticalOffsetPortrait;
@property (nonatomic) CGFloat scalePortrait;
@property (nonatomic) CGFloat horizontalOffsetLandscape;
@property (nonatomic) CGFloat verticalOffsetLandscape;
@property (nonatomic) CGFloat scaleLandscape;
@property (nonatomic) CGFloat verticalOffsetLandscapePhone;
@property (nonatomic) CGFloat scaleLandscapePhone;

@property (nonatomic) BOOL onBoardingCompleted;
@property (nonatomic) NSString* upgradeLastVersion;

@property (nonatomic) BOOL showCase;
@property (nonatomic) BOOL showBand;
@property (nonatomic) NSDictionary* caseImageNames;
@property (nonatomic) NSDictionary* bandImageNames;

+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)reloadPreferences;
- (BOOL)synchronize;

@end

NS_ASSUME_NONNULL_END