BUILD_TARGETS := composer-install
CLEAN_FOLDERS += vendor
ifeq ($(ENV),production)
	COMPOSER_ARGS := --no-dev --optimize-autoloader --prefer-dist --no-suggest
else
	COMPOSER_ARGS := --no-suggest
endif

PHONY += composer-info
composer-info: ## Composer info
	$(call step,Do Composer info...)
	$(call composer_on_${RUN_ON},info)

PHONY += composer-update
composer-update: ## Update Composer packages
	$(call step,Do Composer update...)
	$(call composer_on_${RUN_ON},update)

composer-install: ## Install Composer packages
	$(call step,Do Composer install...)
	$(call composer_on_${RUN_ON},install ${COMPOSER_ARGS})

define composer_on_docker
	$(call docker_run_cmd,cd ${DOCKER_PROJECT_ROOT} && composer --ansi $(1))
endef

define composer_on_host
	@composer --ansi $(1)
endef
