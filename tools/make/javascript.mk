BUILD_TARGETS += js-install
CLEAN_FOLDERS += node_modules
JS_PACKAGE_MANAGER ?= yarn
INSTALLED_NODE_VERSION := $(shell node --version | cut -c2-3 || echo no)
NODE_BIN := $(shell which node || echo no)
NPM_BIN := $(shell which npm || echo no)
YARN_BIN := $(shell which yarn || echo no)
NODE_VERSION ?= 14
NODE_IMG := druidfi/node:$(NODE_VERSION)

PHONY += node-check
node-check: ## Check with Node to use
ifeq ($(INSTALLED_NODE_VERSION),$(NODE_VERSION))
	$(call step,Installed node is the same as target version ($(NODE_VERSION)): Use node on local.)
else
	$(call step,Installed node ($(INSTALLED_NODE_VERSION)) is NOT the same as target version ($(NODE_VERSION)): Use node on Docker $(NVM_VERSION))
	$(call step,You can also use NVM to change your local node version)
endif

PHONY += js-install
js-install: ## Install JS packages
	$(call step,Do $(JS_PACKAGE_MANAGER) install...)
ifeq ($(JS_PACKAGE_MANAGER),yarn)
	$(call node_run,install --frozen-lockfile)
else
	$(call node_run,install --engine-strict true)
endif

ifeq ($(INSTALLED_NODE_VERSION),$(NODE_VERSION))
define node_run
	@$(JS_PACKAGE_MANAGER) $(1)
endef
else
define node_run
	@docker run --rm -v $(CURDIR):/app $(NODE_IMG) /bin/bash -c "$(JS_PACKAGE_MANAGER) $(1)"
endef
endif
