NAI_SIMULATOR ?= 0

CFLAGS = -include Tweak.h

ifneq ($(NAI_SIMULATOR),0)
TARGET := simulator:clang:latest:7.0
ARCHS = x86_64
CFLAGS += -DNAI_SIMULATOR
IOS_SIGNATURE ?= -
TARGET_CODESIGN_FLAGS ?= -s '$(IOS_SIGNATURE)'
else
TARGET := iphone:clang:latest:6.0
ARCHS = arm64e arm64 armv7
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotAnImpostor

NotAnImpostor_FILES = $(wildcard *.mm) $(wildcard *.xm)
NotAnImpostor_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
