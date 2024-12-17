PHONY :=
PROJECT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Colors
NO_COLOR=\033[0m
CYAN=\033[36m
GREEN=\033[0;32m
RED=\033[0;31m
YELLOW=\033[0;33m

ENV := local

# Include project env vars (if exists)
-include .env
-include .env.local

define step
	@printf "\n⭐ ${YELLOW}${1}${NO_COLOR}\n"
endef

PHONY += help
help: ## List all make commands
	$(call step,Available make commands:\n)
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "${CYAN}%-30s${NO_COLOR} %s\n", $$1, $$2}'

# Allow projects to specify makefiles.
-include tools/make/project/*.mk

include tools/make/docker.mk
include tools/make/composer.mk
include tools/make/drupal.mk
include tools/make/git.mk
include tools/make/theme.mk
include tools/make/qa.mk

.PHONY: $(PHONY)
