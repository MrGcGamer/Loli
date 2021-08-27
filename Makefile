TARGET := iphone::latest:latest
INSTALL_TARGET_PROCESSES = SpringBoard

# FINALPACKAGE = 1
THEOS_DEVICE_IP = 192.168.168.100
THEOS_DEVICE_PORT = 22

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Loli

Loli_FILES = Tweak.x
Loli_PRIVATE_FRAMEWORKS = MediaRemote MediaPlayer
Loli_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN -Wdeprecated-declarations -Wno-deprecated-declarations
Loli_LIBRARIES += gcuniversal symbolize

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += loli
include $(THEOS_MAKE_PATH)/aggregate.mk
