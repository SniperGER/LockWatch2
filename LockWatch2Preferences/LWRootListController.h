#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface LWRootListController : PSListController {
	NSBundle* prefBundle;
	NSBundle* localizableBundle;
	
	PSSpecifier* _emulatedDeviceSelectionSpecifier;
}

@end
