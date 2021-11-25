LAGOON_IN_LOCAL ?= no

CLI_SERVICE := cli
CLI_SHELL := bash

INSTANCE_prod_USER ?= project-name-branch
INSTANCE_prod_HOST ?= ssh.lagoon.amazeeio.cloud
INSTANCE_prod_OPTS ?= $(SSH_OPTS) -p 32222 -t
INSTANCE_test_USER ?= project-name-branch
INSTANCE_test_HOST ?= $(INSTANCE_prod_HOST)
INSTANCE_test_OPTS ?= $(INSTANCE_prod_OPTS)

ifeq ($(LAGOON_IN_LOCAL),yes)
	DOCKER_COMPOSE := $(DOCKER_COMPOSE) -f docker-compose.lagoon.yml
endif

PHONY += lagoon-env
lagoon-env: ## Print Lagoon env variables
	$(call docker_run_cmd,printenv | grep LAGOON_)
