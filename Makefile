TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := Super120Hz

Super120Hz_FILES := Sources/Tweak.xm Sources/S120HUD.m Sources/S120Engine.m
Super120Hz_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
Super120Hz_FRAMEWORKS := UIKit Foundation QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
