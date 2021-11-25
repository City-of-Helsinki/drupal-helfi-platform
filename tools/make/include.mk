include $(DRUIDFI_TOOLS_MAKE_DIR)common.mk
include $(DRUIDFI_TOOLS_MAKE_DIR)docker.mk

include $(DRUIDFI_TOOLS_MAKE_DIR)qa.mk

ifeq ($(IS_DRUPAL),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)drupal.mk
endif

ifeq ($(IS_SYMFONY),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)symfony.mk
endif

ifeq ($(IS_WP),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)wordpress.mk
endif

ifeq ($(SYSTEM),LAGOON)
include $(DRUIDFI_TOOLS_MAKE_DIR)lagoon.mk
endif

COMPOSER_JSON_EXISTS := $(shell test -f $(COMPOSER_JSON_PATH)/composer.json && echo yes || echo no)

ifeq ($(COMPOSER_JSON_EXISTS),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)composer.mk
endif

PACKAGE_JSON_EXISTS := $(shell test -f $(PACKAGE_JSON_PATH)/package.json && echo yes || echo no)

ifeq ($(PACKAGE_JSON_EXISTS),yes)
include $(DRUIDFI_TOOLS_MAKE_DIR)javascript.mk
endif

DRUID_CLI_BIN := $(shell command -v druid-cli || echo no)

ifneq ($(DRUID_CLI_BIN),no)
include $(DRUIDFI_TOOLS_MAKE_DIR)druid-cli.mk
endif
