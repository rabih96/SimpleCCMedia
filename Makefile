TARGET = iphone:clang:7.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.1
ARCHS = armv7 armv7s arm64

export THEOS_PACKAGE_DIR_NAME=debs

include theos/makefiles/common.mk

TWEAK_NAME = SimpleCCMedia
SimpleCCMedia_FILES = Tweak.xm
SimpleCCMedia_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
SimpleCCMedia_LIBRARIES = substrate
SimpleCCMedia_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += simpleccmedia
include $(THEOS_MAKE_PATH)/aggregate.mk
