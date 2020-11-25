ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NFCActivator
NFCActivator_FILES = NFCActivator.xm ActivatorEntry.mm
NFCActivator_CFLAGS = -fobjc-arc
NFCActivator_LIBRARIES = activator rocketbootstrap
NFCActivator_EXTRA_FRAMEWORKS = Cephei
NFCActivator_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += nfcactivatorpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
