DRUPAL_CONF_EXISTS := $(shell test -f conf/cmi/core.extension.yml && echo yes || echo no)
DRUPAL_FRESH_TARGETS := up build sync post-install
DRUPAL_NEW_TARGETS := up build drush-si drush-uli
ifeq ($(DRUPAL_VERSION),7)
DRUPAL_POST_INSTALL_TARGETS := drush-updb drush-cr drush-uli
else
DRUPAL_POST_INSTALL_TARGETS := drush-updb drush-cim drush-uli
CLEAN_FOLDERS += ${WEBROOT}/core
CLEAN_FOLDERS += ${WEBROOT}/libraries
CLEAN_FOLDERS += ${WEBROOT}/modules/contrib
CLEAN_FOLDERS += ${WEBROOT}/profiles
CLEAN_FOLDERS += ${WEBROOT}/themes/contrib
endif
DRUPAL_PROFILE ?= minimal
DRUPAL_SYNC_FILES ?= yes
DRUPAL_SYNC_SOURCE ?= production
DRUPAL_VERSION ?= 8
DRUSH_RSYNC_MODE ?= Pakzu
DRUSH_RSYNC_OPTS ?=  -- --omit-dir-times --no-perms --no-group --no-owner --chmod=ugo=rwX
DRUSH_RSYNC_EXCLUDE ?= css:ctools:js:php:tmp:tmp_php
SYNC_TARGETS += drush-sync
LINT_PATHS_JS += ./$(WEBROOT)/modules/custom/*/js
LINT_PATHS_JS += ./$(WEBROOT)/themes/custom/*/js
LINT_PATHS_PHP += -v $(CURDIR)/drush:/app/drush:rw,consistent
LINT_PATHS_PHP += -v $(CURDIR)/$(WEBROOT)/modules/custom:/app/$(WEBROOT)/modules/custom:rw,consistent
LINT_PATHS_PHP += -v $(CURDIR)/$(WEBROOT)/themes/custom:/app/$(WEBROOT)/themes/custom:rw,consistent

# TODO Remove this when DRUPAL_WEBROOT vars are removed from projects
ifdef DRUPAL_WEBROOT
	WEBROOT := $(DRUPAL_WEBROOT)
endif

PHONY += drupal-update
drupal-update: ## Update Drupal core with Composer
	$(call step,Update Drupal core with Composer...)
	@composer update "drupal/core-*" --with-dependencies

PHONY += drush-cex
drush-cex: ## Export configuration
ifeq ($(DRUPAL_VERSION),7)
	$(call warn,\"drush cex\" is not Drupal 7 command\n)
else
	$(call step,Export configuration...)
	$(call drush_on_${RUN_ON},cex -y)
endif

PHONY += drush-cim
drush-cim: ## Import configuration
ifeq ($(DRUPAL_VERSION),7)
	$(call warn,\"drush cim\" is not Drupal 7 command\n)
else
	$(call step,Import configuration...)
	$(call drush_on_${RUN_ON},cim -y)
endif

PHONY += drush-cc
drush-cc: drush-cr

PHONY += drush-cr
drush-cr: ## Clear caches
	$(call step,Clearing caches...)
ifeq ($(DRUPAL_VERSION),7)
	$(call drush_on_${RUN_ON},cc all)
else
	$(call drush_on_${RUN_ON},cr)
endif

PHONY += drush-status
drush-status: ## Show Drupal status information
	$(call drush_on_${RUN_ON},status)

PHONY += drush-uli
drush-uli: ## Get login link
	$(call step,Login to your site with:)
ifeq ($(DRUPAL_VERSION),7)
	$(call drush_on_${RUN_ON},uli)
else
	$(call drush_on_${RUN_ON},uli admin/reports/status)
endif

PHONY += drush-si
ifeq ($(DRUPAL_CONF_EXISTS)$(DRUPAL_VERSION),yes8)
    drush-si: DRUSH_SI := -y --existing-config
else
    drush-si: DRUSH_SI := -y $(DRUPAL_PROFILE)
endif
drush-si: ## Site install
	$(call drush_on_${RUN_ON},si ${DRUSH_SI})

PHONY += drush-deploy
drush-deploy: ## Run Drush deploy
	$(call step,Run Drush deploy...)
	$(call drush_on_${RUN_ON},deploy)

PHONY += drush-updb
drush-updb: ## Run database updates
	$(call step,Run database updates...)
	$(call drush_on_${RUN_ON},updb -y)

PHONY += fresh
fresh: ## Build fresh development environment and sync
	@$(MAKE) $(DRUPAL_FRESH_TARGETS)

PHONY += new
new: ## Create a new empty Drupal installation from configuration
	@$(MAKE) $(DRUPAL_NEW_TARGETS)

PHONY += post-install
post-install: ## Run post-install Drush actions
	@$(MAKE) $(DRUPAL_POST_INSTALL_TARGETS)

PHONY += drush-sync
drush-sync: drush-sync-db drush-sync-files ## Sync database and files

PHONY += drush-sync-db
drush-sync-db: ## Sync database
ifeq ($(DUMP_SQL_EXISTS),yes)
	$(call step,Import local SQL dump...)
	$(call drush_on_${RUN_ON},sql-cli < ${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))
else
	$(call step,Sync database from @$(DRUPAL_SYNC_SOURCE)...)
	$(call drush_on_${RUN_ON},sql-sync -y --structure-tables-key=common @$(DRUPAL_SYNC_SOURCE) @self)
endif

PHONY += drush-sync-files
drush-sync-files: ## Sync files
ifeq ($(DRUPAL_SYNC_FILES),yes)
	$(call step,Sync files from @$(DRUPAL_SYNC_SOURCE)...)
ifeq ($(DRUPAL_VERSION),7)
	@chmod 0755 ${WEBROOT}/sites/default
	@mkdir -p ${WEBROOT}/sites/default/files
	@chmod 0777 ${WEBROOT}/sites/default/files
	$(call drush_on_${RUN_ON},-y rsync --exclude-paths=$(DRUSH_RSYNC_EXCLUDE) --mode=$(DRUSH_RSYNC_MODE) @$(DRUPAL_SYNC_SOURCE):%files @self:%files)
else
	$(call drush_on_${RUN_ON},-y rsync --exclude-paths=$(DRUSH_RSYNC_EXCLUDE) --mode=$(DRUSH_RSYNC_MODE) @$(DRUPAL_SYNC_SOURCE):%files @self:%files $(DRUSH_RSYNC_OPTS))
endif
endif

PHONY += drush-download-dump
drush-download-dump: DOCKER_COMPOSE_EXEC := docker-compose exec
drush-download-dump: ## Download database dump to dump.sql
	$(call drush_on_${RUN_ON},-Dssh.tty=0 @$(DRUPAL_SYNC_SOURCE) sql-dump > ${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

mmfix: MODULE := MISSING_MODULE
mmfix:
	$(call step,Remove missing module '$(MODULE)')
ifeq ($(DRUPAL_VERSION),7)
	$(call drush_on_${RUN_ON},sql-query \"DELETE from system where type = 'module' AND name = '$(MODULE)';\")
else
	$(call drush_on_${RUN_ON},sql-query \"DELETE FROM key_value WHERE collection='system.schema' AND name='module_name';\")
endif

define drush_on_docker
	$(call docker_run_cmd,cd ${DOCKER_PROJECT_ROOT}/${WEBROOT} && drush --ansi --strict=0 $(1))
endef

define drush_on_host
	@drush -r ${DOCKER_PROJECT_ROOT}/${WEBROOT} --ansi --strict=0 $(1)
endef
