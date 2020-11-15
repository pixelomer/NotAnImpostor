NAI_SIMULATOR ?= 0

ifneq ($(NAI_SIMULATOR),0)
TARGET := simulator:clang:latest:7.0
ARCHS = x86_64
TARGET_CODESIGN_FLAGS ?= --sign '$(shell security find-identity -p codesigning -v | head -n 1 | xargs | cut -d " " -f 2)'
else
TARGET := iphone:clang:latest:9.0
ARCHS = arm64e arm64 armv7
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotAnImpostor

NotAnImpostor_FILES = $(wildcard *.mm) $(wildcard *.xm)
NotAnImpostor_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
