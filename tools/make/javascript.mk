BUILD_TARGETS += js-install
CLEAN_FOLDERS += $(PACKAGE_JSON_PATH)/node_modules
JS_PACKAGE_MANAGER ?= yarn
INSTALLED_NODE_VERSION := $(shell command -v node > /dev/null && node --version | cut -c2-3 || echo no)
NODE_BIN := $(shell command -v node || echo no)
NPM_BIN := $(shell command -v npm || echo no)
YARN_BIN := $(shell command -v yarn || echo no)
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

PHONY += js-outdated
js-outdated: ## Show outdated JS packages
	$(call step,Show outdated JS packages with $(JS_PACKAGE_MANAGER)...)
	$(call node_run,outdated)

ifeq ($(INSTALLED_NODE_VERSION),$(NODE_VERSION))
define node_run
	$(call sub_step,Using local $(JS_PACKAGE_MANAGER)...)
	@$(JS_PACKAGE_MANAGER) --cwd $(PACKAGE_JSON_PATH) $(1)
endef
else
define node_run
	$(call sub_step,Using $(NODE_IMG) Docker image...)
	@docker run --rm -v $(PACKAGE_JSON_PATH):/app $(NODE_IMG) /bin/bash -c "$(JS_PACKAGE_MANAGER) --cwd $(PACKAGE_JSON_PATH) $(1)"
endef
endif
