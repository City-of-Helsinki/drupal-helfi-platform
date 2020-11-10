CLI_SERVICE := cli
CLI_SHELL := sh
CLI_USER := root
DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_EXEC ?= $(DOCKER_COMPOSE) exec -T
DOCKER_PROJECT_ROOT ?= /app
DOCKER_WARNING_INSIDE := You are inside the Docker container!

PHONY += config
config: ## Show docker-compose config
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Show docker-compose config...)
	@$(DOCKER_COMPOSE) config
endif

PHONY += down
down: ## Tear down the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Tear down the environment...)
	@$(DOCKER_COMPOSE) down -v --remove-orphans
endif

PHONY += ps
ps: ## Show docker-compose ps
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Show docker-compose ps...)
	@$(DOCKER_COMPOSE) ps
endif

PHONY += stop
stop: ## Stop the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Stop the container(s)...)
	@$(DOCKER_COMPOSE) stop
endif

PHONY += up
up: ## Launch the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Start up the container(s)...)
	@$(DOCKER_COMPOSE) up -d --remove-orphans
endif

PHONY += docker-test
docker-test: ## Run docker targets on Docker and host
	$(call step,Test docker_run_cmd on $(RUN_ON))
	$(call docker_run_cmd,pwd && echo \$$PATH)

PHONY += shell
shell: ## Login to CLI container
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	@$(DOCKER_COMPOSE) exec -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL}
endif

PHONY += ssh-check
ssh-check: ## Check SSH keys on CLI container
	$(call docker_run_cmd,ssh-add -L)

PHONY += versions
versions: ## Show software versions inside the Drupal container
	$(call step,Software versions on ${RUN_ON}:)
	$(call docker_run_cmd,php -v && echo " ")
	$(call composer_on_${RUN_ON}, --version && echo " ")
	$(call drush_on_${RUN_ON},--version)
	$(call docker_run_cmd,echo 'NPM version: '|tr '\n' ' ' && npm --version)
	$(call docker_run_cmd,echo 'Yarn version: '|tr '\n' ' ' && yarn --version)

ifeq ($(RUN_ON),docker)
define docker_run_cmd
	@${DOCKER_COMPOSE_EXEC} -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL} -c "$(1)"
endef
else
define docker_run_cmd
	@$(1)
endef
endif
