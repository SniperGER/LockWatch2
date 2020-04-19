INSTALL_TARGET_PROCESSES = healthd

ARCHS = arm64 arm64e
TARGET = iphone:13.3:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch2Complications

LockWatch2Complications_FILES = $(wildcard *.xm) $(shell find . -type f -name "*.m")
LockWatch2Complications_CFLAGS = -fobjc-arc -I./ -I$(THEOS_PROJECT_DIR)
LockWatch2Complications_LDFLAGS = $(wildcard $(THEOS_PROJECT_DIR)/PrivateFrameworks/*.tbd)
LockWatch2Complications_PRIVATE_FRAMEWORKS = MediaRemote MobileTimer

include $(THEOS_MAKE_PATH)/tweak.mk
