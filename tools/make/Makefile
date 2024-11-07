.DEFAULT_GOAL := help

BUILD_TARGETS :=
COMPOSER_JSON_PATH ?= .
DRUIDFI_TOOLS_MAKE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ENV := dev
PACKAGE_JSON_PATH ?= .
RUN_ON := host
UNAME_S := $(shell uname -s)
# Shorten with https://git.io/ : https://raw.githubusercontent.com/druidfi/tools/main/update.sh
UPDATE_SCRIPT_URL := https://git.io/JP10q
WEBROOT ?= public

include $(DRUIDFI_TOOLS_MAKE_DIR)utils.mk

# Include druidfi/tools make files
include $(DRUIDFI_TOOLS_MAKE_DIR)include.mk

PHONY += debug
debug: ## Show debug information
	@printf "\n$(YELLOW)Debug starts:$(NO_COLOR)\n\n"
	$(call dbg,DOCKER,$(call has,docker))
	$(call dbg,DOCKER_PROJECT_ROOT,$(DOCKER_PROJECT_ROOT))
	$(call dbg,DOCKER_COMPOSE_YML_EXISTS,$(DOCKER_COMPOSE_YML_EXISTS))
	$(call dbg,CLI_SERVICE,$(CLI_SERVICE))
	$(call dbg,CLI_USER,$(if $(CLI_USER),$(CLI_USER),default user from CLI image))
	$(call dbg,CLI_SHELL,${CLI_SHELL})
	$(call dbg,ENV,${ENV})
	$(call dbg,PHP on host,$(call has,php))
	$(call dbg,PHP_BIN,$(shell command -v php || echo no))
	$(call dbg,RUN_ON,${RUN_ON})
	$(call dbg,Composer on host,$(call has,composer))
	$(call dbg,COMPOSER_BIN,$(shell command -v composer || echo no))
	$(call dbg,COMPOSER_JSON_EXISTS,${COMPOSER_JSON_EXISTS})
	$(call dbg,IS_DRUPAL,${IS_DRUPAL})
	$(call dbg,IS_SYMFONY,${IS_SYMFONY})
	$(call dbg,IS_WP,${IS_WP})
	$(call dbg,LAGOON,${LAGOON})
	$(call dbg,WODBY,${WODBY})
	$(call dbg,SYSTEM,${SYSTEM})
	$(call dbg,WEBROOT,${WEBROOT})
	$(call dbg,UNAME_S,${UNAME_S})
ifeq ($(RUN_ON),docker)
	@printf "\n${YELLOW}Assumption: We should run on Docker and not on host${NO_COLOR}\n"
else
	@printf "\n${YELLOW}Assumption: We should run on host and not on Docker${NO_COLOR}\n"
endif
	@printf "\n${GREEN}End of debug.${NO_COLOR}\n"
