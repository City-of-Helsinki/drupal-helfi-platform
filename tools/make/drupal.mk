BUILD_TARGETS += drupal-create-folders
DRUPAL_CONF_EXISTS := $(shell test -f conf/cmi/core.extension.yml && echo yes || echo no)
DRUPAL_FRESH_TARGETS := up build sync post-install
DRUPAL_NEW_TARGETS := up build drush-si drush-uli
DRUPAL_POST_INSTALL_TARGETS := drush-deploy
CLEAN_EXCLUDE += $(WEBROOT)/sites/default/files
DRUPAL_DISABLE_MODULES ?= no
DRUPAL_ENABLE_MODULES ?= no
DRUPAL_PROFILE ?= minimal
DRUPAL_SYNC_FILES ?= yes
DRUPAL_SYNC_SOURCE ?= main
DRUSH_RSYNC_MODE ?= Pakzu
DRUSH_RSYNC_OPTS ?=  -- --omit-dir-times --no-perms --no-group --no-owner --chmod=ugo=rwX
DRUSH_RSYNC_EXCLUDE ?= css:ctools:js:php:tmp:tmp_php
SYNC_TARGETS += drush-sync
CS_EXTS := inc,php,module,install,profile,theme
CS_STANDARD_PATHS := vendor/drupal/coder/coder_sniffer,vendor/slevomat/coding-standard
CS_STANDARDS := Drupal,DrupalPractice
LINT_PATHS_JS += ./$(WEBROOT)/modules/custom/*/js
LINT_PATHS_JS += ./$(WEBROOT)/themes/custom/*/js
LINT_PATHS_PHP += drush
LINT_PATHS_PHP += $(WEBROOT)/modules/custom
LINT_PATHS_PHP += $(WEBROOT)/themes/custom
LINT_PHP_TARGETS += lint-drupal
FIX_TARGETS += fix-drupal
DRUPAL_CREATE_FOLDERS := $(WEBROOT)/sites/default/files/private
DRUPAL_CREATE_FOLDERS += $(WEBROOT)/sites/default/files/translations

ifeq ($(GH_DUMP_ARTIFACT),yes)
	DRUPAL_FRESH_TARGETS := gh-download-dump $(DRUPAL_FRESH_TARGETS)
endif

ifneq ($(DRUPAL_DISABLE_MODULES),no)
	SYNC_TARGETS += drush-disable-modules
endif

ifneq ($(DRUPAL_ENABLE_MODULES),no)
	DRUPAL_POST_INSTALL_TARGETS += drush-enable-modules
endif

PHONY += drupal-create-folders
drupal-create-folders:
	$(call step,Create folders for Drupal...\n)
	$(call docker_compose_exec,mkdir -v -p $(DRUPAL_CREATE_FOLDERS))

PHONY += drupal-update
drupal-update: ## Update Drupal core with Composer
	$(call step,Update Drupal core with Composer...\n)
	$(call composer,update -W "drupal/core-*")

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
	$(call drush,uli$(if $(DRUPAL_UID), --uid=$(DRUPAL_UID),) $(DRUPAL_DESTINATION))

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

PHONY += fresh
fresh: ## Build fresh development environment and sync
	@$(MAKE) $(DRUPAL_FRESH_TARGETS)

PHONY += new
new: ## Create a new empty Drupal installation from configuration
	@$(MAKE) $(DRUPAL_NEW_TARGETS)

PHONY += post-install
post-install: ## Run post-install Drush actions
	@$(MAKE) $(DRUPAL_POST_INSTALL_TARGETS) drush-uli

PHONY += drush-disable-modules
drush-disable-modules: ## Disable Drupal modules
	$(call step,Disable Drupal modules...\n)
ifneq ($(DRUPAL_DISABLE_MODULES),no)
	$(call drush,pmu -y $(subst ",,$(DRUPAL_DISABLE_MODULES)))
else
	$(call sub_step,No modules to disable)
endif

PHONY += drush-enable-modules
drush-enable-modules: ## Enable Drupal modules
	$(call step,Enable Drupal modules...\n)
ifneq ($(DRUPAL_ENABLE_MODULES),no)
	$(call drush,en -y $(subst ",,$(DRUPAL_ENABLE_MODULES)))
else
	$(call sub_step,No modules to enable)
endif

PHONY += drush-sync
drush-sync: drush-sync-db drush-sync-files ## Sync database and files

PHONY += drush-sync-db
drush-sync-db: ## Sync database
	$(call drush,sql-drop --quiet -y)
ifeq ($(DUMP_SQL_EXISTS),yes)
	$(call step,Import local SQL dump...)
	$(call drush,sql-query --file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME) && echo 'SQL dump imported')
else
	$(call step,Sync database from @$(DRUPAL_SYNC_SOURCE)...)
	$(call drush,sql-sync -y --structure-tables-key=common @$(DRUPAL_SYNC_SOURCE) @self)
endif

PHONY += drush-sync-files
drush-sync-files: ## Sync files
ifeq ($(DRUPAL_SYNC_FILES),yes)
	$(call step,Sync files from @$(DRUPAL_SYNC_SOURCE)...)
	$(call drush,-y rsync --exclude-paths=$(DRUSH_RSYNC_EXCLUDE) --mode=$(DRUSH_RSYNC_MODE) @$(DRUPAL_SYNC_SOURCE):%files @self:%files $(DRUSH_RSYNC_OPTS))
endif

PHONY += drush-create-dump
drush-create-dump: FLAGS := --structure-tables-key=common --extra-dump=--no-tablespaces
drush-create-dump: ## Create database dump to dump.sql
	$(call drush,sql-dump $(FLAGS) --result-file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

PHONY += drush-download-dump
drush-download-dump: ## Download database dump to dump.sql
	$(call drush,@$(DRUPAL_SYNC_SOURCE) sql-dump --structure-tables-key=common > ${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

PHONY += open-db-gui
open-db-gui: ## Open database with GUI tool
	$(eval DB_SERVICE ?= db)
	$(eval DB_NAME ?= drupal)
	$(eval DB_USER ?= drupal)
	$(eval DB_PASS ?= drupal)
	@open mysql://$(DB_USER):$(DB_PASS)@$(shell docker compose port $(DB_SERVICE) 3306 | grep -v ::)/$(DB_NAME)

PHONY += fix-drupal
fix-drupal: PATHS := $(subst $(space),,$(LINT_PATHS_PHP))
fix-drupal: ## Fix Drupal code style
	$(call step,Fix Drupal code style with phpcbf...\n)
	$(call cs,phpcbf,$(PATHS))

PHONY += lint-drupal
lint-drupal: PATHS := $(subst $(space),,$(LINT_PATHS_PHP))
lint-drupal: ## Lint Drupal code style
	$(call step,Lint Drupal code style with phpcs...\n)
	$(call cs,phpcs,$(PATHS))

PHONY += mmfix
mmfix: MODULE := MISSING_MODULE
mmfix:
	$(call step,Remove missing module '$(MODULE)'\n)
	$(call drush,sql-query \"DELETE FROM key_value WHERE collection='system.schema' AND name='$(MODULE)';\",Module was removed)

ifeq ($(RUN_ON),docker)
define drush
	$(call docker_compose_exec,drush $(1),$(2))
endef
else
define drush
	@drush $(1)
endef
endif
