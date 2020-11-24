DRUPAL_NEW_TARGETS := up build drush-si drush-enable-modules drush-uli

PHONY += drush-enable-modules
drush-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush_on_docker,en -y features helfi_base_config)
