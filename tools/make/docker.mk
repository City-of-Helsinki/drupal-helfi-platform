CLI_SERVICE := cli
CLI_SHELL := sh
CLI_USER := root
DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_EXEC ?= $(DOCKER_COMPOSE) exec
DOCKER_PROJECT_ROOT ?= /app
DOCKER_WARNING_INSIDE := You are inside the Docker container!

PHONY += config
config: ## Show docker-compose config
	$(call docker_compose,config,Show docker-compose config...)

PHONY += down
down: ## Tear down the environment
	$(call docker_compose,down -v --remove-orphans --rmi local,Tear down the environment...)

PHONY += ps
ps: ## Show docker-compose ps
	$(call docker_compose,ps,Show docker-compose ps...)

PHONY += stop
stop: ## Stop the environment
	$(call docker_compose,stop,Stop the container(s)...)

PHONY += up
up: ## Launch the environment
	$(call docker_compose,up -d --remove-orphans --quiet-pull,Start up the container(s)...)

PHONY += shell
shell: ## Login to CLI container
ifeq ($(RUN_ON),docker)
	@$(DOCKER_COMPOSE) exec -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL}
else
	$(call warn,$(DOCKER_WARNING_INSIDE))
endif

PHONY += ssh-check
ssh-check: ## Check SSH keys on CLI container
	$(call docker_run_cmd,ssh-add -L)

ifeq ($(RUN_ON),docker)
define docker_run_cmd
	@${DOCKER_COMPOSE_EXEC} -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL} -c "$(1) && echo $(2)"
endef
else
define docker_run_cmd
	@$(1) && echo $(2)
endef
endif

ifeq ($(RUN_ON),docker)
define docker_compose
	$(call step,$(2)\n)
	@$(DOCKER_COMPOSE) $(1)
endef
else
define docker_compose
	$(call sub_step,$(DOCKER_WARNING_INSIDE))
endef
endif
