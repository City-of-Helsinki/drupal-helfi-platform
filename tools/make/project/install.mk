ifeq ($(DRUPAL_VERSION),8)
	ifeq ($(DRUPAL_CONF_EXISTS),yes)
	    DRUPAL_NEW_TARGETS := up build drush-si drush-cr drush-locale-update drush-uli
	else
	    DRUPAL_NEW_TARGETS := up build drush-si drush-enable-modules drush-locale-update drush-uli
	endif
    DRUPAL_POST_INSTALL_TARGETS := drush-deploy drush-locale-update drush-uli
endif

OC_LOGIN_TOKEN ?= $(shell bash -c 'read -s -p "You must obtain an API token by visiting https://oauth-openshift.apps.arodevtest.hel.fi/oauth/token/request (Token):" token; echo $$token')
SYNC_TARGETS := oc-login oc-sync

PHONY += oc-login
oc-login:
	$(call drush,helfi:oc:login $(OC_LOGIN_TOKEN))

PHONY += oc-sync
oc-sync:
	$(call drush,helfi:oc:get-dump)
	$(call drush,sql-query --file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME),SQL dump imported)
	$(call drush,helfi:oc:sanitize-database)
	$(call drush,cr)
	$(call drush,cim -y)
	$(call drush,cr)

PHONY += drush-enable-modules
drush-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush,cr)
	$(call drush,en -y helfi_platform_config helfi_base_config)

PHONY += drush-locale-update
drush-locale-update: ## Update translations.
	$(call step,Update translations...)
	$(call drush,state:set locale.translation_last_checked 0)
	$(call drush_on_docker,locale:check)
	$(call drush_on_docker,locale:update)
	$(call drush_on_docker,cr)
	$(call step,Import custom translations...)
	$(call drush,helfi:locale-import helfi_platform_config)
