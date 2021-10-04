ifeq ($(DRUPAL_VERSION),8)
	ifeq ($(DRUPAL_CONF_EXISTS),yes)
	    DRUPAL_NEW_TARGETS := up build drush-si drush-locale-update drush-cr drush-uli
	else
	    DRUPAL_NEW_TARGETS := up build drush-si drush-enable-modules drush-locale-update drush-uli
	endif
    DRUPAL_POST_INSTALL_TARGETS := drush-deploy drush-locale-update drush-uli
endif

PHONY += drush-enable-modules
drush-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...\n)
	$(call drush,cr)
	$(call drush,en -y helfi_platform_config helfi_base_config)

PHONY += drush-enable-example-content
drush-enable-example-content: ## Enable example content.
	$(call step,Install HELfi Example content...\n)
	$(call drush,cr)
	$(call drush,en -y helfi_example_content)

PHONY += drush-locale-update
drush-locale-update: ## Update translations.
	$(call step,Update translations...\n)
	$(call drush,state:set locale.translation_last_checked 0)
	$(call drush,locale:update)
	$(call step,Import custom translations...\n)
	$(call drush,helfi:locale-import helfi_platform_config)
