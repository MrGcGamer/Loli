TARGET := iphone::13.0:13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Loli

Loli_FILES = $(wildcard *.m)
Loli_FRAMEWORKS = UIKit
Loli_PRIVATE_FRAMEWORKS = Preferences
Loli_INSTALL_PATH = /Library/PreferenceBundles
Loli_LIBRARIES += gcuniversal symbolize
Loli_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
