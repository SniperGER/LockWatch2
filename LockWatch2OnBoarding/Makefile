ARCHS = arm64 arm64e
TARGET = iphone:13.3:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch2OnBoarding

LockWatch2OnBoarding_FILES = $(wildcard *.xm) $(wildcard *.m) $(wildcard Controllers/*.m) $(wildcard Views/*.m)
LockWatch2OnBoarding_CFLAGS = -fobjc-arc -I./ -I../ -include ../Prefix.pch
LockWatch2OnBoarding_PRIVATE_FRAMEWORKS = BulletinBoard ClockKit NanoRegistry NanoTimeKitCompanion OnBoardingKit
LockWatch2OnBoarding_FRAMEWORKS = AVFoundation AVKit

include $(THEOS_MAKE_PATH)/tweak.mk
