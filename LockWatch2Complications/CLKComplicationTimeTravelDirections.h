//
// CLKComplicationTimeTravelDirections.h
// LockWatch
//
// Created by janikschmidt on 8/12/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

typedef NS_OPTIONS(NSUInteger, CLKComplicationTimeTravelDirections) {
/*  0 */	CLKComplicationTimeTravelDirectionNone      = 0,
/*  1 */	CLKComplicationTimeTravelDirectionForward   = 1 << 0,
/*  2 */	CLKComplicationTimeTravelDirectionBackward  = 1 << 1,
};