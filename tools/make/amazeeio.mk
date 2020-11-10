LAGOON_IN_LOCAL ?= no

ifeq ($(AMAZEEIO_LAGOON),yes)
	CLI_SERVICE := cli
	INSTANCE_prod_USER ?= project-name-branch
	INSTANCE_prod_HOST ?= ssh.lagoon.amazeeio.cloud
	INSTANCE_prod_OPTS ?= $(SSH_OPTS) -p 32222 -t
	INSTANCE_test_USER ?= project-name-branch
	INSTANCE_test_HOST ?= $(INSTANCE_prod_HOST)
	INSTANCE_test_OPTS ?= $(INSTANCE_prod_OPTS)
ifeq ($(LAGOON_IN_LOCAL),yes)
	DOCKER_COMPOSE := docker-compose -f docker-compose.lagoon.yml
endif
else
	CLI_SERVICE := drupal
	CLI_USER := drupal
	DOCKER_PROJECT_ROOT := /var/www/drupal/public_html
	INSTANCE_prod_USER ?= sitegroup_branch
    INSTANCE_prod_HOST ?= fi1.compact.amazee.io
    INSTANCE_prod_OPTS ?= $(SSH_OPTS)
    INSTANCE_test_USER ?= sitegroup_branch
    INSTANCE_test_HOST ?= $(INSTANCE_prod_HOST)
    INSTANCE_test_OPTS ?= $(SSH_OPTS)
endif

CLI_SHELL := bash

PHONY += amazeeio-env
amazeeio-env: ## Print Amazee.io env variables
	$(call docker_run_cmd,printenv | grep AMAZEE)
