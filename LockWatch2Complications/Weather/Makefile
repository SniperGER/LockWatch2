ARCHS = arm64 arm64e
TARGET = iphone:13.3:latest

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = LockWatch2Weather

LockWatch2Weather_FILES = $(shell find . -type f -name "*.m")
LockWatch2Weather_CFLAGS = -fobjc-arc -I./ -I../
LockWatch2Weather_LDFLAGS = $(shell find . -type f -name "*.tbd")
LockWatch2Weather_PRIVATE_FRAMEWORKS += ClockKit NanoTimeKitCompanion Weather WeatherFoundation NanoWeatherComplicationsCompanion

include $(THEOS_MAKE_PATH)/library.mk
