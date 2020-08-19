//
// NTKComplicationFamily.h
// LockWatch2
//
// Created by janikschmidt on 3/29/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

typedef NS_ENUM(NSUInteger, CLKComplicationFamily) {
	/**
	 * A small square area that ClockKit displays on the Modular watch face.
	 */
	CLKComplicationFamilyModularSmall,			// 0
	
	/**
	 * A large rectangular area that ClockKit displays on the Modular watch face.
	 */
	CLKComplicationFamilyModularLarge,			// 1
	
	/**
	 * A small square or rectangular area that ClockKit Displays on the Utility, Mickey, Chronograph, and Simple watch faces.
	 */
	CLKComplicationFamilyUtilitarianSmall,		// 2
	
	/**
	 * A large rectangular area that spans the width of the screen in the Utility and Mickey watch faces.
	 */
	CLKComplicationFamilyUtilitarianLarge,		// 3
	
	/**
	 * A small square or rectangular area that ClockKit Displays on the Utility, Mickey, Chronograph, and Simple watch faces.
	 */
	CLKComplicationFamilyCircularSmall,			// 4
	
	/**
	 * A small circular area that ClockKit displays on the Color watch face.
	 */
	CLKComplicationFamilyUnknown,				// 5
	
	/**
	 * A small rectangular area that ClockKit Displays on the Photos, Motion, and Timelapse watch faces.
	 */
	CLKComplicationFamilyUtilitarianSmallFlat,	// 6
	
	/**
	 * A large square area that ClockKit displays on the X-Large watch face.
	 */
	CLKComplicationFamilyExtraLarge,			// 7
	
	/**
	 * A curved area that fills the corners in the Infograph watch face.
	 */
	CLKComplicationFamilyGraphicCorner,			// 8
	
	/**
	 * A circular area with optional curved text that ClockKit displays along the bezel of the Infograph watch face.
	 */
	CLKComplicationFamilyGraphicBezel,			// 9
	
	/**
	 * A circular area that ClockKit displays on the Infograph and Infograph Modular watch faces.
	 */
	CLKComplicationFamilyGraphicCircular,		// 10
	
	/**
	 * A large rectangular area that ClockKit displays in the center of the Infograph Modular watch face.
	 */
	CLKComplicationFamilyGraphicRectangular,	// 11
	
	/**
	 * A small rectangular area that is used to display the current date
	 */
	CLKComplicationFamilyDate = 100,			// 100
	
	/**
	 * A small rectangular area that is used to display user-selectable initials
	 */
	CLKComplicationFamilyMonogram,				// 101
	
	/**
	 * A small rectangular area that ClockKit displays on upper half the Hermès watch face
	 */
	CLKComplicationFamilyZeusUpper,				// 102
	
	/**
	 * A small rectangular area that ClockKit displays on lower half the Hermès watch face
	 */
	CLKComplicationFamilyZeusLower,				// 103
	
	/**
	 * A large rectangular area that spans the width of the screen in the Motion watch face.
	 */
	CLKComplicationFamilyUtilLargeNarrow,		// 104
	
	/**
	 * A circular area that ClockKit displays on the Nike Digital watch face.
	 */
	CLKComplicationFamilyCircularMedium,		// 105
	
	/**
	 * A complication family that seemingly displays simple text, used for the Digital Time complication.
	 */
	CLKComplicationFamilySimpleText				// 106
};