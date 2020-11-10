PHONY += help
help: ## List all make commands
	$(call step,Available make commands:)
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

# Colors
NO_COLOR=\033[0m
GREEN=\033[0;32m
RED=\033[0;31m
YELLOW=\033[0;33m

define dbg
	@printf "${GREEN}${1}:${NO_COLOR} ${2}\n"
endef

define step
	@printf "\n⚡ ${YELLOW}${1}${NO_COLOR}\n\n"
endef

define warn
	@printf "\n⚠️  ${1}\n\n"
endef
