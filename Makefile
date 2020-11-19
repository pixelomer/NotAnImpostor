NAI_TARGET ?= iOS

# Native variables
CFLAGS = -include Tweak.h

ifeq ($(NAI_TARGET),iOS)

# iOS (native)
ARCHS = arm64e arm64 armv7
TARGET := iphone:clang:latest:6.0
CFLAGS += -DNAI_TARGET_IOS

else
ifeq ($(NAI_TARGET),tvOS)

# tvOS (native)
ARCHS = arm64 arm64e
TARGET := appletv:clang:latest:12.0
CFLAGS += -DNAI_TARGET_TVOS

else

# iOS (simulator)
ARCHS = x86_64
TARGET := simulator:clang:latest:7.0
CFLAGS += -DNAI_TARGET_SIMULATOR
IOS_SIGNATURE ?= -
TARGET_CODESIGN_FLAGS ?= -s '$(IOS_SIGNATURE)'

ifeq ($(NAI_TARGET),tvOS_Simulator)

# tvOS (simulator)
CFLAGS += -DNAI_TARGET_TVOS=1 -Wno-overriding-t-option -target x86_64-apple-tvos11.2.0 -isysroot $(shell xcode-select -p)/Platforms/AppleTVSimulator.platform/Developer/SDKs/AppleTVSimulator.sdk
LDFLAGS += -Wno-overriding-t-option -target x86_64-apple-tvos11.2.0 -isysroot $(shell xcode-select -p)/Platforms/AppleTVSimulator.platform/Developer/SDKs/AppleTVSimulator.sdk

else
ifeq ($(NAI_TARGET),iOS_Simulator)

# iOS (simulator)
CFLAGS += -DNAI_TARGET_IOS=1

else

$(error NAI_TARGET environment variable contains an invalid value. It should be tvOS, iOS, tvOS_Simulator or iOS_Simulator)

endif # iOS (simulator)
endif # tvOS (simulator)
endif # tvOS
endif # iOS

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotAnImpostor

NotAnImpostor_FILES = $(wildcard *.mm) $(wildcard *.xm)
NotAnImpostor_CFLAGS = -fobjc-arc -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk
