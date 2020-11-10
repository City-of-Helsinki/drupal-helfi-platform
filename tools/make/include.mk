include $(DRUIDFI_TOOLS_MAKE_DIR)common.mk
include $(DRUIDFI_TOOLS_MAKE_DIR)docker.mk

ifeq ($(COMPOSER_JSON_EXISTS),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)composer.mk
endif

ifeq ($(PACKAGE_JSON_EXISTS),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)javascript.mk
endif

ifeq ($(IS_DRUPAL),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)drupal.mk
endif

ifeq ($(IS_SYMFONY),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)symfony.mk
endif

ifeq ($(IS_WP),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)wordpress.mk
endif

ifeq ($(SYSTEM),AMAZEEIO)
include $(DRUIDFI_TOOLS_MAKE_DIR)amazeeio.mk
endif

include $(DRUIDFI_TOOLS_MAKE_DIR)qa.mk
