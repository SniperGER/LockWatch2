THEOS_DEVICE_IP = Janiks-iPhone-X.local

PACKAGE_VERSION = $(shell cat VERSION)
ARCHS = arm64 arm64e
TARGET = iphone:13.3:latest
# ARCHS = x86_64
# TARGET = simulator:clang::latest

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch2

LockWatch2_FILES = $(wildcard *.xm) $(wildcard Core/*.m) $(wildcard LockScreen/*.m)
LockWatch2_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)
LockWatch2_PRIVATE_FRAMEWORKS = ClockKit NanoRegistry NanoTimeKitCompanion Preferences ProtocolBuffer

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(THEOS_TARGET_NAME), iphone)
SUBPROJECTS += LockWatch2Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
