CLI_SERVICE := app
CLI_SHELL := sh
# Note: specification says this file would be compose.yaml
DOCKER_COMPOSE_YML_PATH ?= compose.yaml
DOCKER_COMPOSE_YML_EXISTS := $(shell test -f $(DOCKER_COMPOSE_YML_PATH) && echo yes || echo no)
DOCKER_PROJECT_ROOT ?= /app
DOCKER_WARNING_INSIDE := You are inside the Docker container!

# If docker-compose.yml exists
ifeq ($(DOCKER_COMPOSE_YML_EXISTS),yes)
	RUN_ON := docker
endif

PHONY += config
config: ## Show docker-compose config
	$(call step,Show Docker Compose config...\n)
	$(call docker_compose,config)

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
ifeq ($(RUN_ON),docker)
	$(call docker_compose,exec $(CLI_SERVICE) $(CLI_SHELL))
else
	$(call warn,$(DOCKER_WARNING_INSIDE))
endif

PHONY += ssh-check
ssh-check: ## Check SSH keys on CLI container
	$(call docker_compose_exec,ssh-add -L)

ifeq ($(RUN_ON),docker)
define docker
	@docker $(1) > /dev/null 2>&1 && $(if $(2),echo "$(2)",)
endef
else
define docker
	$(call sub_step,$(DOCKER_WARNING_INSIDE))
endef
endif

ifeq ($(RUN_ON),docker)
define docker_compose_exec
	$(call docker_compose,exec$(if $(CLI_USER), -u $(CLI_USER),) $(CLI_SERVICE) $(CLI_SHELL) -c "$(1)")
	$(if $(2),@echo "$(2)",)
endef
else
define docker_compose_exec
	@$(1) && echo $(2)
endef
endif

ifeq ($(RUN_ON),docker)
define docker_compose
	@docker compose$(if $(filter $(DOCKER_COMPOSE_YML_PATH),$(DOCKER_COMPOSE_YML_PATH)),, -f $(DOCKER_COMPOSE_YML_PATH)) $(1)
endef
else
define docker_compose
	$(call sub_step,$(DOCKER_WARNING_INSIDE))
endef
endif
