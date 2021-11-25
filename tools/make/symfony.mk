SF_FRESH_TARGETS := up build sf-cw sf-about sf-open
FIX_TARGETS += fix-symfony
LINT_PHP_TARGETS += lint-symfony
CLEAN_FOLDERS += $(COMPOSER_JSON_PATH)/var

PHONY += encore-dev
encore-dev: ## Do Encore development build
	$(call step,Do Encore development build...)
	$(call node_run,dev)

PHONY += encore-watch
encore-watch: ## Run Encore watch
	$(call step,Do Encore watch...)
	$(call node_run,watch)

PHONY += sf-about
sf-about: ## Displays information about the current project
	$(call sf_console,about)

PHONY += sf-cc
sf-cc: ## Clear Symfony caches
	$(call step,Clear Symfony caches...)
	$(call sf_console,cache:clear)

PHONY += sf-cw
sf-cw: ## Warm Symfony caches
	$(call step,Warm Symfony caches...)
	$(call sf_console,cache:warmup)

PHONY += sf-db-init
sf-db-init: ## Setup database schema and load fixtures
	$(call step,Setup database schema...)
	$(call sf_console,doctrine:schema:update --force)
	$(call sf_console,doctrine:fixtures:load -n)

PHONY += sf-open
sf-open: ## Warm Symfony caches
	$(call step,See your Symfony application with:\n)
	$(call output,https://$(APP_HOST))

PHONY += sf-update
sf-update: ## Update Symfony packages with Composer
	$(call step,Update Symfony packages with Composer...\n)
	$(call composer,update -W "doctrine/*" "symfony/*" "twig/*" --no-scripts)

PHONY += fresh
fresh: ## Build fresh development environment
	@$(MAKE) $(SF_FRESH_TARGETS)

PHONY += fix-symfony
fix-symfony: ## Fix Symfony code style
	$(call step,Fix Symfony code style in ./src ...\n)
	@docker run --rm -it -v $(CURDIR)/src:/app/src:rw,consistent druidfi/qa:php-$(call get_php_version) bash -c "php-cs-fixer -vvvv fix src"

PHONY += lint-symfony
lint-symfony: VOLUMES := $(CURDIR)/src:/app/src:rw,consistent
lint-symfony: ## Lint Symfony code style
	$(call step,Lint Symfony code style...\n)
	@docker run --rm -it -v $(VOLUMES) druidfi/qa:php-$(call get_php_version) bash -c "phpcs ."

ifeq ($(RUN_ON),docker)
define sf_console
	$(call docker_run_cmd,bin/console $(1))
endef
else
define sf_console
	@bin/console
endef
endif
