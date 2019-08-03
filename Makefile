THEOS_DEVICE_IP = haotestlabs.com
THEOS_DEVICE_PORT = 28262

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NFCActivator
NFCActivator_FILES = Tweak.xm activatorEntry.mm
NFCActivator_CFLAGS = -fobjc-arc
NFCActivator_LIBRARIES = activator
NFCActivator_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += nfcactivatorpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
