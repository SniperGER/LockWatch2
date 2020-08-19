//
// LWDigitalTimeComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 4/11/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWDigitalTimeComplicationDataSource : LWComplicationDataSourceBase

- (CLKComplicationTemplate*)_templateWithShouldDisplayIdealizeState:(BOOL)shouldDisplayIdealizeState;

@end

NS_ASSUME_NONNULL_END