//
// LWSiriComplicationDataSource.h
// LockWatch
//
// Created by janikschmidt on 8/16/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "LWComplicationDataSourceBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWSiriComplicationDataSource : LWComplicationDataSourceBase {
	BOOL _forceHero;
	BOOL _siriEnabled;
}

@end

NS_ASSUME_NONNULL_END