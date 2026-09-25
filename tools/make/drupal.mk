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
	$(call drush,helfi:locale-import helfi_platform_config)
	$(call drush,cr)

DRUPAL_POST_INSTALL_TARGETS := drush-sanitize-database drush-deploy drush-unblock drush-uli

DRUPAL_FRESH_TARGETS := up drupal-create-folders composer-install drush-import-dump $(DRUPAL_POST_INSTALL_TARGETS)
PHONY += fresh
fresh: $(DRUPAL_FRESH_TARGETS) ## Build fresh development environment and sync

DRUPAL_NEW_TARGETS := up drupal-create-folders composer-install drush-si drush-helfi-enable-modules drush-cr drush-unblock drush-uli
PHONY += new
new: $(DRUPAL_NEW_TARGETS) ## Create a new empty Drupal installation from configuration

# Azure CLI credentials are stored on the host and shared between projects,
# so you only need to log in once. Override in .env.local if needed.
AZURE_CLI_CONFIG_DIR ?= $(HOME)/.azure-helfi
AZURE_CLI_IMAGE ?= mcr.microsoft.com/azure-cli:latest
# Storage account, container and blob holding the database dump. The
# container is project specific and must be set in .env.
AZURE_DUMP_STORAGE_ACCOUNT ?= stplattaopsdevtest
AZURE_DUMP_CONTAINER ?=
AZURE_DUMP_BLOB ?= testing.sql
AZURE_DUMP_AUTH_MODE ?= login

define azure_cli
	@mkdir -p $(AZURE_CLI_CONFIG_DIR)
	@docker run --pull=always -it --rm \
		--user $(shell id -u):$(shell id -g) \
		-e HOME=/tmp -e AZURE_CONFIG_DIR=/azure \
		-v $(AZURE_CLI_CONFIG_DIR):/azure \
		-v $(CURDIR):/app -w /app \
		$(AZURE_CLI_IMAGE) sh -c "$(1)"
endef

AZURE_LOGIN_CMD := az login --use-device-code

PHONY += azure-login
azure-login: ## Log in to Azure (credentials are shared between projects)
	$(call step,Log in to Azure...\n)
	$(call azure_cli,$(AZURE_LOGIN_CMD))

PHONY += azure-logout
azure-logout: ## Log out from Azure
	$(call azure_cli,az logout)

AZURE_DUMP_BLOB_ARGS := --auth-mode $(AZURE_DUMP_AUTH_MODE) \
	--account-name $(AZURE_DUMP_STORAGE_ACCOUNT) \
	--container-name $(AZURE_DUMP_CONTAINER) \
	--name $(AZURE_DUMP_BLOB)

dump.sql:
	$(if $(AZURE_DUMP_CONTAINER),,$(error AZURE_DUMP_CONTAINER is not set))
	$(call step,Download $(AZURE_DUMP_BLOB) from Azure Blob storage...\n)
	$(call azure_cli,az account show > /dev/null 2>&1 || $(AZURE_LOGIN_CMD) && \
		exists=\$$(az storage blob exists $(AZURE_DUMP_BLOB_ARGS) --query exists -o tsv) || exit 1; \
		if [ \"\$$exists\" != true ]; then \
			echo 'Blob $(AZURE_DUMP_BLOB) does not exist in container $(AZURE_DUMP_CONTAINER).' >&2; \
			echo 'Run the database pipeline for this project to create it and try again.' >&2; \
			exit 1; \
		fi && \
		az storage blob download $(AZURE_DUMP_BLOB_ARGS) --file /app/dump.sql.part > /dev/null)
	@mv dump.sql.part dump.sql
	@printf "Downloaded dump.sql (%s)\n" "$$(du -h dump.sql | cut -f1)"

PHONY += drush-import-dump
drush-import-dump: dump.sql
	$(call drush,sql-drop --quiet -y)
	$(call step,Import local SQL dump...)
	$(call drush,sql-query --file=/app/dump.sql --extra=--skip-ssl && echo 'SQL dump imported')

PHONY += drush-sanitize-database
drush-sanitize-database:
	$(call drush,sql-query --extra=--skip-ssl \"UPDATE file_managed SET uri = REPLACE(uri, 'azure://', 'public://');\",Fixed Azure URIs)

PHONY += drush-create-dump
drush-create-dump: ## Create database dump to dump.sql
	$(call drush,sql-dump --structure-tables-key=common --extra-dump='--no-tablespaces --skip-ssl' --result-file=/app/dump.sql)

PHONY += open-db-gui
open-db-gui: ## Open database with GUI tool
	$(eval DB_SERVICE ?= db)
	$(eval DB_NAME ?= drupal)
	$(eval DB_USER ?= drupal)
	$(eval DB_PASS ?= drupal)
	@open mysql://$(DB_USER):$(DB_PASS)@$(shell docker compose port $(DB_SERVICE) 3306 | grep -v ::)/$(DB_NAME)

ifeq ($(IS_CONTAINER),false)
define drush
	$(call docker_compose_exec,drush $(1),$(2))
endef
else
define drush
	@drush $(1) $(2)
endef
endif
