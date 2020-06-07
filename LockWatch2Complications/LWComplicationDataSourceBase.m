//
// LWComplicationDataSourceBase.m
// LockWatch
//
// Created by janikschmidt on 3/30/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

@implementation LWComplicationDataSourceBase

+ (BOOL)acceptsComplicationType:(NSUInteger)type forDevice:(CLKDevice*)device {
	return YES;
}

+ (BOOL)acceptsComplicationFamily:(long long)family forDevice:(CLKDevice*)device {
	return YES;
}

- (CLKComplicationTemplate*)currentSwitcherTemplate {
	return nil;
}

- (void)getCurrentTimelineEntryWithHandler:(void (^)(CLKComplicationTimelineEntry* timelineEntry))handler {
	handler(nil);
}

- (void)getSupportedTimeTravelDirectionsWithHandler:(void (^)(long long family))handler {
	handler(self.family);
}

- (void)getTimelineEndDateWithHandler:(void (^)(NSDate* date))handler {
	handler(NSDate.distantFuture);
}

- (void)getTimelineEntriesAfterDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler {
	handler(nil);
}

- (void)getTimelineEntriesBeforeDate:(NSDate*)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray* _Nullable entries))handler {
	handler(nil);
}

- (void)getTimelineStartDateWithHandler:(void (^)(NSDate* date))handler {
	handler(NSDate.distantPast);
}

@end