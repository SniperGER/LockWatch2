SHARED_CFLAGS = -fobjc-arc
CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -fobjc-arc
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockWatch2Preferences

LockWatch2Preferences_FILES = $(wildcard *.m) $(wildcard *.mm)
LockWatch2Preferences_INSTALL_PATH = /Library/PreferenceBundles
LockWatch2Preferences_FRAMEWORKS = UIKit WebKit
LockWatch2Preferences_PRIVATE_FRAMEWORKS = ClockKit NanoRegistry Preferences SpringBoardServices
LockWatch2Preferences_CFLAGS = -fobjc-arc -include ../Prefix.pch

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LockWatch2Preferences.plist$(ECHO_END)
