#import "LockScreen/LWClockViewController.h"

#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.lockwatch2.list"

/**
 * Headers
 */

@class CSCoverSheetViewController, CSMainPageContentViewController, SBFLockScreenDateViewController;

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (CSCoverSheetViewController*)coverSheetViewController;
@end

@interface CSCoverSheetViewController : UIViewController
- (CSMainPageContentViewController*)mainPageContentViewController;
- (SBFLockScreenDateViewController*)dateViewController;
@end

@interface CSMainPageContentViewController : UIViewController
@end

@interface SBFLockScreenDateViewController : UIViewController
@end

@interface SBFLockScreenDateView : UIView
@end

@interface CSScrollView : UIView
@end

@interface SBBacklightController : NSObject
@property(nonatomic, readonly) BOOL screenIsOn;
@end

/**
 * Instances
 */

static LWClockViewController* clockViewController;