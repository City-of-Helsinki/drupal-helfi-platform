PHONY += composer-update
composer-update: ## Update Composer packages
	$(call step,Do Composer update...\n)
	$(call composer,update)

PHONY += composer-install
composer-install: ## Install Composer packages
	$(call step,Do Composer install...\n)
	$(call composer,install)

PHONY += composer-outdated
composer-outdated: ## Show outdated Composer packages
	$(call step,Show outdated Composer packages...\n)
	$(call composer,outdated --direct)

define composer
	$(call docker_compose_exec,composer $(1))
endef
