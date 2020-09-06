THEOS_DEVICE_IP = Janiks-iPhone-X.local

PACKAGE_VERSION = $(shell cat VERSION)
ARCHS = arm64 arm64e
TARGET = iphone:13.3:latest
# ARCHS = x86_64
# TARGET = simulator:clang:13.2:latest
# TARGET_CODESIGN = 

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch2

LockWatch2_FILES = $(wildcard *.xm) $(wildcard *.m) $(wildcard Core/*.m) $(wildcard LockScreen/*.m)
LockWatch2_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR) -I$(THEOS_PROJECT_DIR)/Headers -include Prefix.pch
LockWatch2_PRIVATE_FRAMEWORKS = ClockKit MaterialKit MobileTimer NanoRegistry NanoTimeKitCompanion Preferences ProtocolBuffer SpringBoardUIServices

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += LockWatch2Complications

ifeq ($(THEOS_TARGET_NAME), iphone)
SUBPROJECTS += LockWatch2Preferences
SUBPROJECTS += LockWatch2OnBoarding
endif

include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	@find . -name ".DS_Store" -delete