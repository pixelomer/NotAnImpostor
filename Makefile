TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotAnImpostor

NotAnImpostor_FILES = $(wildcard *.mm) $(wildcard *.xm)
NotAnImpostor_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
