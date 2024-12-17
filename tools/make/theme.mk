DEFAULT_NODE_VERSION ?= 20
NODE_DOCKER_RUN_EXTRA_ARGS ?= -it

ifeq ($(CI),true)
	NODE_DOCKER_RUN_EXTRA_ARGS =
endif

PHONY += install-hdbt-subtheme
install-hdbt-subtheme: ## Installs dependencies for HDBT subtheme
	$(call node,/public/themes/custom/hdbt_subtheme,"npm install")

PHONY += build-hdbt-subtheme
build-hdbt-subtheme: ## Builds SCSS/JS assets for HDBT subtheme
	$(call node,/public/themes/custom/hdbt_subtheme,"npm run build")

PHONY += watch-hdbt-subtheme
watch-hdbt-subtheme: ## Starts SCSS/JS watcher for HDBT subtheme
	$(call node,/public/themes/custom/hdbt_subtheme,"npm run dev")

PHONY += install-hdbt
install-hdbt: ## Installs dependencies for HDBT theme
	$(call node,/public/themes/contrib/hdbt,"npm install")

PHONY += build-hdbt
build-hdbt: ## Builds SCSS/JS assets for HDBT theme
	$(call node,/public/themes/contrib/hdbt,"npm run build")

PHONY += watch-hdbt
watch-hdbt: ## Starts SCSS/JS watcher for HDBT theme
	$(call node,/public/themes/contrib/hdbt,"npm run dev")

PHONY += install-hdbt-admin
install-hdbt-admin: ## Installs dependencies for HDBT Admin theme
	$(call node,/public/themes/contrib/hdbt_admin,"npm install")

PHONY += build-hdbt-admin
build-hdbt-admin: ## Builds SCSS/JS assets for HDBT Admin theme
	$(call node,/public/themes/contrib/hdbt_admin,"npm run build")

PHONY += watch-hdbt-admin
watch-hdbt-admin: ## Starts SCSS/JS watcher for HDBT Admin theme
	$(call node,/public/themes/contrib/hdbt_admin,"npm run dev")

PHONY += node-shell
node-shell: ## Login to node container
	$(call node,,sh)

define node_version
$(strip $(shell cat $(PROJECT_DIR)/$(1)/.nvmrc 2>/dev/null || echo $(DEFAULT_NODE_VERSION))-alpine)
endef

define node
	docker run $(NODE_DOCKER_RUN_EXTRA_ARGS) --rm --name helfi-node-$(call node_version,$(1)) -v $(shell pwd):/app -w /app$(1) node:$(call node_version,$(1)) "$(2)"
endef
