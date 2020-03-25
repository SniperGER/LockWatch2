SHARED_CFLAGS = -fobjc-arc
CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -fobjc-arc
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = lockwatch2

lockwatch2_FILES = $(wildcard *.m) $(wildcard *.mm)
lockwatch2_INSTALL_PATH = /Library/PreferenceBundles
lockwatch2_FRAMEWORKS = UIKit WebKit
lockwatch2_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices
lockwatch2_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/lockwatch2.plist$(ECHO_END)
