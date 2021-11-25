BUILD_TARGETS := composer-install
CLEAN_FOLDERS += $(COMPOSER_JSON_PATH)/vendor

PHONY += composer-info
composer-info: ## Composer info
	$(call step,Do Composer info...\n)
	$(call composer,info)

PHONY += composer-update
composer-update: ## Update Composer packages
	$(call step,Do Composer update...\n)
	$(call composer,update)

PHONY += composer-install
composer-install: ## Install Composer packages
	$(call step,Do Composer install...\n)
ifeq ($(ENV),production)
	$(call composer,install --no-dev --optimize-autoloader --prefer-dist)
else
	$(call composer,install)
endif

PHONY += composer-outdated
composer-outdated: ## Show outdated Composer packages
	$(call step,Show outdated Composer packages...\n)
	$(call composer,outdated --direct)

ifeq ($(RUN_ON),docker)
define composer
	$(call docker_run_cmd,cd ${DOCKER_PROJECT_ROOT} && composer --ansi --working-dir=$(COMPOSER_JSON_PATH) $(1))
endef
else
define composer
	@composer --ansi --working-dir=$(COMPOSER_JSON_PATH) $(1)
endef
endif

define get_php_version
$(shell docker compose exec ${CLI_SERVICE} ${CLI_SHELL} -c "php -v | grep ^PHP | cut -d' ' -f2 | cut -c0-3")
endef
