ifeq ($(DRUPAL_CONF_EXISTS)$(DRUPAL_VERSION),no8)
    DRUPAL_NEW_TARGETS := up build drush-si drush-enable-modules drush-locale-import drush-uli
    DRUPAL_POST_INSTALL_TARGETS := drush-updb drush-cim drush-locale-import drush-uli
endif

PHONY += drush-enable-modules
drush-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush_on_docker,en -y helfi_platform_config helfi_base_config)

PHONY += drush-locale-import
drush-locale-import: ## Import locale PO files
	$(call step,Import locale PO files...)
	$(call drush_on_docker,helfi:locale-import helfi_platform_config)
