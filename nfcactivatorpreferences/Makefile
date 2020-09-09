DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NFCActivatorPreferences
NFCActivatorPreferences_FILES = NAPRootViewController.m NAPEditViewController.mm NAPDiscoveryViewController.mm
NFCActivatorPreferences_INSTALL_PATH = /Library/PreferenceBundles
NFCActivatorPreferences_FRAMEWORKS = UIKit
NFCActivatorPreferences_PRIVATE_FRAMEWORKS = Preferences
NFCActivatorPreferences_CFLAGS = -fobjc-arc
NFCActivatorPreferences_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NFCActivatorPreferences.plist$(ECHO_END)
