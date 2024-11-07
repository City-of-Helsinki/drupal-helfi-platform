ifeq ($(DRUPAL_CONF_EXISTS),yes)
	DRUPAL_NEW_TARGETS := up build drush-si drush-cr drush-locale-update drush-helfi-locale-import drush-unblock drush-uli
else
	DRUPAL_NEW_TARGETS := up build drush-si drush-helfi-enable-modules drush-locale-update drush-helfi-locale-import drush-unblock drush-uli
endif
DRUPAL_POST_INSTALL_TARGETS := drush-deploy drush-locale-update drush-helfi-locale-import drush-unblock

OC_LOGIN_TOKEN ?= $(shell bash -c 'read -s -p "You must obtain an API token by visiting https://oauth-openshift.apps.arodevtest.hel.fi/oauth/token/request (Token):" token; echo $$token')

SYNC_TARGETS := drush-sync-db

ifneq ($(DUMP_SQL_EXISTS),yes)
SYNC_TARGETS := oc-login oc-sync
endif

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

PHONY += drush-helfi-enable-modules
drush-helfi-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush,cr)
	$(call drush,en -y helfi_platform_config helfi_platform_config_base)

PHONY += drush-locale-update
drush-locale-update: ## Update translations.
	$(call step,Update translations...)
	@mkdir -p public/sites/default/files/translations
	$(call drush,state:set locale.translation_last_checked 0)
	$(call drush,locale:check)
	$(call drush,locale:update)
	$(call drush,cr)

PHONY += drush-helfi-locale-import
drush-helfi-locale-import:  ## Update translations from helfi platform config.
	$(call step,Import helfi platform config translations...)
	$(call drush,helfi:locale-import helfi_platform_config)
	$(call drush,cr)

PHONY += drush-unblock
drush-unblock: ## Get login link
	$(call step,Unblocking helfi-admin...\n)
	$(call drush,user:unblock --uid=1)
