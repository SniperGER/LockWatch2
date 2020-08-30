#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController ()
- (BOOL)containsSpecifier:(PSSpecifier*)specifier;
@end

@interface LWRootListController : PSListController {
	NSBundle* prefBundle;
	NSBundle* localizableBundle;
	
	PSSpecifier* _emulatedDeviceSelectionSpecifier;
}

@end
