DRUPAL_CONF_EXISTS := $(shell test -f conf/cmi/core.extension.yml && echo yes || echo no)
DRUPAL_FRESH_TARGETS := up build sync post-install
DRUPAL_NEW_TARGETS := up build drush-si drush-uli
ifeq ($(DRUPAL_VERSION),7)
DRUPAL_POST_INSTALL_TARGETS := drush-updb drush-cr drush-uli
else
DRUPAL_POST_INSTALL_TARGETS := drush-deploy drush-uli
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
LINT_PHP_TARGETS += lint-drupal
FIX_TARGETS += fix-drupal

ifeq ($(GH_DUMP_ARTIFACT),yes)
	DRUPAL_FRESH_TARGETS := gh-download-dump $(DRUPAL_FRESH_TARGETS)
endif

PHONY += drupal-update
drupal-update: ## Update Drupal core with Composer
	$(call step,Update Drupal core with Composer...\n)
	$(call composer,update -W "drupal/core-*")

PHONY += drush-cex
drush-cex: ## Export configuration
ifeq ($(DRUPAL_VERSION),7)
	$(call warn,\"drush cex\" is not Drupal 7 command\n)
else
	$(call step,Export configuration...\n)
	$(call drush,cex -y)
endif

PHONY += drush-cim
drush-cim: ## Import configuration
ifeq ($(DRUPAL_VERSION),7)
	$(call warn,\"drush cim\" is not Drupal 7 command\n)
else
	$(call step,Import configuration...\n)
	$(call drush,cim -y)
endif

PHONY += drush-cc
drush-cc: drush-cr

PHONY += drush-cr
drush-cr: ## Clear caches
	$(call step,Clearing caches...\n)
ifeq ($(DRUPAL_VERSION),7)
	$(call drush,cc all)
else
	$(call drush,cr)
endif

PHONY += drush-status
drush-status: ## Show Drupal status information
	$(call drush,status)

PHONY += drush-uli
drush-uli: ## Get login link
	$(call step,Login to your site with:\n)
ifeq ($(DRUPAL_VERSION),7)
	$(call drush,uli)
else
	$(call drush,uli admin/reports/status)
endif

PHONY += drush-si
ifeq ($(DRUPAL_CONF_EXISTS)$(DRUPAL_VERSION),yes8)
    drush-si: DRUSH_SI := -y --existing-config
else
    drush-si: DRUSH_SI := -y $(DRUPAL_PROFILE)
endif
drush-si: ## Site install
	$(call drush,si ${DRUSH_SI})

PHONY += drush-deploy
drush-deploy: ## Run Drush deploy
	$(call step,Run Drush deploy...\n)
	$(call drush,deploy)

PHONY += drush-updb
drush-updb: ## Run database updates
	$(call step,Run database updates...\n)
	$(call drush,updb -y)

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
	$(call drush,sql-query --file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME),SQL dump imported)
else
	$(call step,Sync database from @$(DRUPAL_SYNC_SOURCE)...)
ifeq ($(DRUPAL_VERSION),7)
	$(call drush,sql-drop -y)
endif
	$(call drush,sql-sync -y --structure-tables-key=common @$(DRUPAL_SYNC_SOURCE) @self)
endif

PHONY += drush-sync-files
drush-sync-files: ## Sync files
ifeq ($(DRUPAL_SYNC_FILES),yes)
	$(call step,Sync files from @$(DRUPAL_SYNC_SOURCE)...)
ifeq ($(DRUPAL_VERSION),7)
	@chmod 0755 ${WEBROOT}/sites/default
	@mkdir -p ${WEBROOT}/sites/default/files
	@chmod 0777 ${WEBROOT}/sites/default/files
	$(call drush,-y rsync --exclude-paths=$(DRUSH_RSYNC_EXCLUDE) --mode=$(DRUSH_RSYNC_MODE) @$(DRUPAL_SYNC_SOURCE):%files @self:%files)
else
	$(call drush,-y rsync --exclude-paths=$(DRUSH_RSYNC_EXCLUDE) --mode=$(DRUSH_RSYNC_MODE) @$(DRUPAL_SYNC_SOURCE):%files @self:%files $(DRUSH_RSYNC_OPTS))
endif
endif

PHONY += drush-create-dump
drush-create-dump: FLAGS := --structure-tables-key=common --extra-dump=--no-tablespaces
drush-create-dump: ## Create database dump to dump.sql
	$(call drush,sql-dump $(FLAGS) --result-file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

PHONY += drush-download-dump
drush-download-dump: ## Download database dump to dump.sql
	$(call drush,-Dssh.tty=0 @$(DRUPAL_SYNC_SOURCE) sql-dump --structure-tables-key=common > ${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

PHONY += fix-drupal
fix-drupal: VOLUMES := $(subst $(space),,$(LINT_PATHS_PHP))
fix-drupal: ## Fix Drupal code style
	$(call step,Fix Drupal code style...)
	@docker run --rm -it $(VOLUMES) druidfi/qa:php-$(call get_php_version) bash -c "phpcbf --runtime-set drupal_core_version $(DRUPAL_VERSION) ."

PHONY += lint-drupal
lint-drupal: VOLUMES := $(subst $(space),,$(LINT_PATHS_PHP))
lint-drupal: ## Lint Drupal code style
	$(call step,Lint Drupal code style with...)
	@docker run --rm -it $(VOLUMES) druidfi/qa:php-$(call get_php_version) bash -c "phpcs --runtime-set drupal_core_version $(DRUPAL_VERSION) ."

PHONY += mmfix
mmfix: MODULE := MISSING_MODULE
mmfix:
	$(call step,Remove missing module '$(MODULE)')
ifeq ($(DRUPAL_VERSION),7)
	$(call drush,sql-query \"DELETE from system where type = 'module' AND name = '$(MODULE)';\",Module was removed)
else
	$(call drush,sql-query \"DELETE FROM key_value WHERE collection='system.schema' AND name='$(MODULE)';\",Module was removed)
endif

ifeq ($(RUN_ON),docker)
ifeq ($(DRUPAL_VERSION),7)
define drush
	$(call docker_run_cmd,cd ${DOCKER_PROJECT_ROOT}/${WEBROOT} && drush --ansi --strict=0 $(1),$(2))
endef
else
define drush
	$(call docker_run_cmd,drush --ansi --strict=0 $(1),$(2))
endef
endif
else
define drush
	@cd $(COMPOSER_JSON_PATH)/${WEBROOT} && drush --ansi --strict=0 $(1)
endef
endif
