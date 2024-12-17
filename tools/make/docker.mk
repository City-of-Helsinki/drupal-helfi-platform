PHONY += pull
pull: ## Pull docker images
	$(call step,Pull the latest docker images...\n)
	$(call docker_compose,pull)

PHONY += down
down: ## Tear down the environment
	$(call step,Tear down the environment...\n)
	$(call docker_compose,down -v --remove-orphans --rmi local)

PHONY += ps
ps: ## List containers
	$(call step,List container(s)...\n)
	$(call docker_compose,ps)

PHONY += stop
stop: ## Stop the environment
	$(call step,Stop the container(s)...\n)
	$(call docker_compose,stop)

PHONY += up
up: ## Launch the environment
	$(call step,Start up the container(s)...\n)
	$(call docker_compose,up --wait --remove-orphans)

PHONY += shell
shell: ## Login to CLI container
	$(call docker_compose,exec app bash)

define docker_compose_exec
	$(call docker_compose,exec app bash -c "$(1)")
endef

define docker_compose
	@docker compose $(1)
endef

