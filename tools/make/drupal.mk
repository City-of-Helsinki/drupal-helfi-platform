DUMP_SQL_EXISTS := $(shell test -f dump.sql && echo yes || echo no)
DRUPAL_CONF_EXISTS := $(shell test -f conf/cmi/core.extension.yml && echo yes || echo no)

DRUPAL_CREATE_FOLDERS := /app/public/sites/default/files/private
DRUPAL_CREATE_FOLDERS += /app/public/sites/default/files/translations

DRUPAL_PROFILE ?= minimal

PHONY += drupal-create-folders
drupal-create-folders:
	$(call step,Create folders for Drupal...\n)
	$(call docker_compose_exec,mkdir -v -p $(DRUPAL_CREATE_FOLDERS))

PHONY += drush-cex
drush-cex: ## Export configuration
	$(call step,Export configuration...\n)
	$(call drush,cex -y)

PHONY += drush-cim
drush-cim: ## Import configuration
	$(call step,Import configuration...\n)
	$(call drush,cim -y)

PHONY += drush-cr
drush-cr: ## Clear caches
	$(call step,Clearing caches...\n)
	$(call drush,cr)

PHONY += drush-status
drush-status: ## Show Drupal status information
	$(call drush,status)

PHONY += drush-uli
drush-uli: DRUPAL_UID ?=
drush-uli: DRUPAL_DESTINATION ?= admin/reports/status
drush-uli: ## Get login link
	$(call step,Login to your site with:\n)
	$(call drush,uli $(DRUPAL_DESTINATION))

PHONY += drush-uli-%
drush-uli-%: ## Get login link for provided uid
	$(call step,Login to your site as user $* with:\n)
	$(call drush,uli --uid=$*)

PHONY += drush-si
ifeq ($(DRUPAL_CONF_EXISTS),yes)
    drush-si: DRUSH_SI := -y --existing-config
else
    drush-si: DRUSH_SI := -y $(DRUPAL_PROFILE)
endif
drush-si: ## Site install
	$(call step,Do Drush site:install...\n)
	$(call drush,si ${DRUSH_SI})

PHONY += drush-helfi-enable-modules
drush-helfi-enable-modules: ## Enable modules and base configurations.
	$(call step,Install base configurations...)
	$(call drush,cr)
	$(call drush,en -y helfi_platform_config helfi_platform_config_base)

PHONY += drush-deploy
drush-deploy: ## Run Drush deploy
	$(call step,Run Drush deploy...\n)
	$(call drush,deploy)

PHONY += drush-updb
drush-updb: ## Run database updates
	$(call step,Run database updates...\n)
	$(call drush,updb -y)

PHONY += drush-reset-local
drush-reset-local: ## Reset local configuration (cim, cr, updb, cr)
	$(call step,Reset local configuration...\n)
	$(call drush,cim -y)
	$(call drush,cr)
	$(call drush,updb -y --no-cache-clear)
	$(call drush,cr)

PHONY += drush-unblock
drush-unblock: ## Get login link
	$(call step,Unblocking helfi-admin...\n)
	$(call drush,user:unblock --uid=1)

PHONY += drush-locale-update
drush-locale-update: drupal-create-folders ## Update translations.
	$(call step,Update translations...)
	$(call drush,locale:clear-status)
	$(call drush,locale:check)
	$(call drush,locale:update)
	$(call drush,cr)

DRUPAL_POST_INSTALL_TARGETS := drush-sanitize-database drush-deploy drush-locale-update drush-unblock drush-uli

DRUPAL_FRESH_TARGETS := up drupal-create-folders composer-install drush-import-dump $(DRUPAL_POST_INSTALL_TARGETS)
PHONY += fresh
fresh: $(DRUPAL_FRESH_TARGETS) ## Build fresh development environment and sync

DRUPAL_NEW_TARGETS := up drupal-create-folders composer-install drush-si drush-helfi-enable-modules drush-cr drush-unblock drush-uli
PHONY += new
new: $(DRUPAL_NEW_TARGETS) ## Create a new empty Drupal installation from configuration

dump.sql:
	@touch /tmp/kube-config
	@docker run --pull=always --env-file .env -it --rm -v /tmp/kube-config:/root/.kube/config -v $(shell pwd):/app --name helfi-oc ghcr.io/city-of-helsinki/drupal-oc-cli:latest sh -c "db-sync"
	$(call docker_compose_exec,gunzip dump.sql.gz)

PHONY += drush-import-dump
drush-import-dump: dump.sql
	$(call drush,sql-drop --quiet -y)
	$(call step,Import local SQL dump...)
	$(call drush,sql-query --file=/app/dump.sql && echo 'SQL dump imported')

PHONY += drush-sanitize-database
drush-sanitize-database:
	$(call drush,sql-query \"UPDATE file_managed SET uri = REPLACE(uri, 'azure://', 'public://');\",Fixed Azure URIs)

PHONY += drush-create-dump
drush-create-dump: ## Create database dump to dump.sql
	$(call drush,sql-dump --structure-tables-key=common --extra-dump=--no-tablespaces --result-file=/app/dump.sql)

PHONY += open-db-gui
open-db-gui: ## Open database with GUI tool
	$(eval DB_SERVICE ?= db)
	$(eval DB_NAME ?= drupal)
	$(eval DB_USER ?= drupal)
	$(eval DB_PASS ?= drupal)
	@open mysql://$(DB_USER):$(DB_PASS)@$(shell docker compose port $(DB_SERVICE) 3306 | grep -v ::)/$(DB_NAME)

define drush
	$(call docker_compose_exec,drush $(1),$(2))
endef
