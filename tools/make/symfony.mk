SF_FRESH_TARGETS := up build sf-about

PHONY += sf-about
sf-about: ## Displays information about the current project
	$(call sf_console_on_${RUN_ON},about)

PHONY += sf-cc
sf-cc: ## Clear Symfony caches
	$(call sf_console_on_${RUN_ON},cache:clear)
	$(call sf_console_on_${RUN_ON},cache:warmup)

PHONY += fresh
fresh: ## Build fresh development environment and sync
	@$(MAKE) $(SF_FRESH_TARGETS)

define sf_console_on_docker
	$(call docker_run_cmd,bin/console --ansi $(1))
endef

define sf_console_on_host
	@bin/console --ansi $(1)
endef
