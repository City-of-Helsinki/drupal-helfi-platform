ifeq ($(DRUPAL_CONF_EXISTS)$(DRUPAL_VERSION),no8)
    DRUPAL_NEW_TARGETS := up build drush-si drush-enable-modules drush-uli
endif

PHONY += drush-enable-modules
drush-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush_on_docker,en -y helfi_platform_config)
