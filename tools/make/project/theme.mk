PHONY += install-hdbt-subtheme
install-hdbt-subtheme: ## Installs dependencies for HDBT subtheme
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm install")

PHONY += build-hdbt-subtheme
build-hdbt-subtheme: ## Builds SCSS/JS assets for HDBT subtheme
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm run build")

PHONY += watch-hdbt-subtheme
watch-hdbt-subtheme: ## Starts SCSS/JS watcher for HDBT subtheme
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm run dev")

PHONY += install-hdbt
install-hdbt: ## Installs dependencies for HDBT theme
	$(call node,/app/public/themes/contrib/hdbt,"npm install")

PHONY += build-hdbt
build-hdbt: ## Builds SCSS/JS assets for HDBT theme
	$(call node,/app/public/themes/contrib/hdbt,"npm run build")

PHONY += watch-hdbt
watch-hdbt: ## Starts SCSS/JS watcher for HDBT theme
	$(call node,/app/public/themes/contrib/hdbt,"npm run dev")

PHONY += install-hdbt-admin
install-hdbt-admin: ## Installs dependencies for HDBT Admin theme
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm install")

PHONY += build-hdbt-admin
build-hdbt-admin: ## Builds SCSS/JS assets for HDBT Admin theme
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm run build")

PHONY += watch-hdbt-admin
watch-hdbt-admin: ## Starts SCSS/JS watcher for HDBT Admin theme
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm run dev")

PHONY += node-shell
node-shell: ## Login to node container
	$(call node,/app,sh)

define node
	@docker compose exec -w $(1) node "$(2)"
endef
