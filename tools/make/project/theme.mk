PHONY += install-hdbt-subtheme
install-hdbt-subtheme:
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm install")

PHONY += build-hdbt-subtheme
build-hdbt-subtheme:
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm run build")

PHONY += watch-hdbt-subtheme
watch-hdbt-subtheme:
	$(call node,/app/public/themes/custom/hdbt_subtheme,"npm run dev")

PHONY += install-hdbt
install-hdbt:
	$(call node,/app/public/themes/contrib/hdbt,"npm install")

PHONY += build-hdbt
build-hdbt:
	$(call node,/app/public/themes/contrib/hdbt,"npm run build")

PHONY += watch-hdbt
watch-hdbt:
	$(call node,/app/public/themes/contrib/hdbt,"npm run dev")

PHONY += install-hdbt-admin
install-hdbt-admin:
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm install")

PHONY += build-hdbt-admin
build-hdbt-admin:
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm run build")

PHONY += watch-hdbt-admin
watch-hdbt-admin:
	$(call node,/app/public/themes/contrib/hdbt_admin,"npm run dev")

PHONY += node shell
node-shell:
	$(call node,/app,sh)

define node
	@docker compose exec -w $(1) node "$(2)"
endef
