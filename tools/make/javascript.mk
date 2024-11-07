BUILD_TARGETS += js-install
JS_PACKAGE_MANAGER ?= yarn
JS_PACKAGE_MANAGER_CWD_FLAG_NPM ?= --prefix
JS_PACKAGE_MANAGER_CWD_FLAG_YARN ?= --cwd
INSTALLED_NODE_VERSION := $(shell command -v node > /dev/null && node --version | cut -c2-3 || echo no)
NVM_SH := $(HOME)/.nvm/nvm.sh
NVM := $(shell test -f "$(NVM_SH)" && echo yes || echo no)
NODE_BIN := $(shell command -v node || echo no)
NPM_BIN := $(shell command -v npm || echo no)
YARN_BIN := $(shell command -v yarn || echo no)
NODE_VERSION ?= 16

PHONY += js-install
js-install: ## Install JS packages
ifeq ($(JS_PACKAGE_MANAGER),yarn)
	$(call node_run,install --frozen-lockfile)
else
	$(call node_run,install --no-audit --no-fund --engine-strict true)
endif

PHONY += js-outdated
js-outdated: ## Show outdated JS packages
	$(call step,Show outdated JS packages with $(JS_PACKAGE_MANAGER)...)
	$(call node_run,outdated)

ifeq ($(NVM),no)
define node_run
	$(call error,$(NVM_REQUIRED))
endef
else
define node_run
	$(call step,Run '$(JS_PACKAGE_MANAGER) $(1)' with Node $(NODE_VERSION)...\n)
	@. $(NVM_SH) && (nvm which $(NODE_VERSION) > /dev/null 2>&1 || nvm install $(NODE_VERSION)) && \
		nvm exec $(NODE_VERSION) $(JS_PACKAGE_MANAGER) $(if $(filter $(JS_PACKAGE_MANAGER),yarn),$(JS_PACKAGE_MANAGER_CWD_FLAG_YARN),$(JS_PACKAGE_MANAGER_CWD_FLAG_NPM)) $(PACKAGE_JSON_PATH) $(1)
endef
endif

define NVM_REQUIRED


🚫 NVM is required to run $(JS_PACKAGE_MANAGER) commands and control Node versions!


endef
