THEOS_DEVICE_IP = Janiks-iPad-Pro.local

PACKAGE_VERSION = 2.0b1
ARCHS = arm64
TARGET = iphone:11.2:latest

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch2

LockWatch2_FILES = $(wildcard *.xm) $(wildcard Core/*.m) $(wildcard LockScreen/*.m)
LockWatch2_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR) -I$(THEOS_PROJECT_DIR)/Headers
LockWatch2_LDFLAGS = $(wildcard PrivateFrameworks/*.tbd)

include $(THEOS_MAKE_PATH)/tweak.mk
