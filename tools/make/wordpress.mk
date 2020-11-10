WP_FRESH_TARGETS := up build sync post-install
WP_POST_INSTALL_TARGETS := prepare
WP_CONF_PATH := conf
WP_DELETE_PLUGINS := akismet hello
WP_DELETE_THEMES := twentynineteen twentyseventeen
WP_SQL_READY := yes
DUMP_SQL_FILENAME := wordpress.sql
DUMP_SQL_EXISTS := $(shell test -f $(DUMP_SQL_FILENAME) && echo yes || echo no)
SYNC_TARGETS += wp-sync-db wp-sync-files

PHONY += fresh
fresh: ## Build fresh development environment
	@$(MAKE) $(WP_FRESH_TARGETS)

PHONY += post-install
post-install: ## Run post-install actions
	@$(MAKE) $(WP_POST_INSTALL_TARGETS)

PHONY += prepare
prepare:
	$(call step,Remove obsolete files)
	@rm -f $(WEBROOT)/*.{txt,html} $(WEBROOT)/composer.json && printf "Files deleted.\n"
	$(call step,Copy $(WP_CONF_PATH)/wp-config.php to $(WEBROOT)...)
	@cp -v $(WP_CONF_PATH)/wp-config.php $(WEBROOT)/wp-config.php
	$(call step,Delete inactivated plugins)
	$(call wp,plugin delete $(WP_DELETE_PLUGINS))
	$(call step,Delete inactivated themes)
	$(call wp,theme delete $(WP_DELETE_THEMES))
	$(call step,Replace $(WP_SYNC_SOURCE) domain with local domain)
	$(call wp,search-replace $(WP_SYNC_SOURCE_DOMAIN) $(WP_HOSTNAME))
	$(call step,Check your site: https://$(WP_HOSTNAME))

PHONY += wp-sync-db
wp-sync-db: ## Sync database
ifeq ($(DUMP_SQL_EXISTS),yes)
	$(call step,Import local SQL dump...)
	$(call wp,db import $(DUMP_SQL_FILENAME))
else
	$(call step,Create database dump in $(WP_SYNC_SOURCE)...)
	$(eval HOST := INSTANCE_$(WP_SYNC_SOURCE)_HOST)
	$(eval USER := INSTANCE_$(WP_SYNC_SOURCE)_USER)
	$(eval OPTS := INSTANCE_$(WP_SYNC_SOURCE)_OPTS)
	@ssh $($(OPTS)) $($(USER))@$($(HOST)) -t "cd $(DOCKER_PROJECT_ROOT)/$(WEBROOT); wp db export $(DUMP_SQL_FILENAME); exit;"
	$(call step,Download $(DUMP_SQL_FILENAME) from test server...)
	@scp $($(OPTS)) $($(USER))@$($(HOST)):/var/www/html/$(WEBROOT)/$(DUMP_SQL_FILENAME) ./$(DUMP_SQL_FILENAME)
	$(call step,Remove the $(DUMP_SQL_FILENAME) from $(WP_SYNC_SOURCE)...)
	@ssh $($(OPTS)) $($(USER))@$($(HOST)) -t "rm $(DOCKER_PROJECT_ROOT)/$(WEBROOT)/$(DUMP_SQL_FILENAME); exit;" && echo "Removed"
	$(call step,Import $(DUMP_SQL_FILENAME) to local database...)
	$(call wp,db import $(DUMP_SQL_FILENAME))
endif

PHONY += wp-sync-files
wp-sync-files: UPLOADS := wp-content/uploads
wp-sync-files: ## Sync files
	$(call step,Sync files from $(WP_SYNC_SOURCE)...)
	$(eval HOST := INSTANCE_$(WP_SYNC_SOURCE)_HOST)
	$(eval USER := INSTANCE_$(WP_SYNC_SOURCE)_USER)
	$(eval OPTS := INSTANCE_$(WP_SYNC_SOURCE)_OPTS)
	@rsync -av -e "ssh $($(OPTS))" $($(USER))@$($(HOST)):$(DOCKER_PROJECT_ROOT)/$(WEBROOT)/$(UPLOADS)/ $(WEBROOT)/$(UPLOADS)/

PHONY += wp-cache-flush
wp-cache-flush: ## Flush cache
	$(call step,Flush cache)
	$(call wp,cache flush)

PHONY += wp-help
wp-help: ## Show wp-cli help
	$(call wp,)

PHONY += wp-plugins
wp-plugins: ## List plugins
	$(call step,List plugins)
	$(call wp,plugin list)

define wp
	@${DOCKER_COMPOSE_EXEC} php ${CLI_SHELL} -c "wp --color --path=$(DOCKER_PROJECT_ROOT)/$(WEBROOT) $(1)"
endef

ifeq ($(WP_SYNC_SOURCE),)
  $(error WP_SYNC_SOURCE is not set. Add eg. WP_SYNC_SOURCE=prod to .env file)
endif

ifeq ($(WP_SYNC_SOURCE_DOMAIN),)
  $(error WP_SYNC_SOURCE_DOMAIN is not set. Add eg. WP_SYNC_SOURCE_DOMAIN=domain.tld to .env file)
endif
