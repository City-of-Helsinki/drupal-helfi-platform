CLI_SERVICE := cli
CLI_SHELL := bash
DB_SERVICE := mariadb

INSTANCE_prod_USER ?= project-name-branch
INSTANCE_prod_HOST ?= ssh.lagoon.amazeeio.cloud
INSTANCE_prod_OPTS ?= $(SSH_OPTS) -p 32222 -t
INSTANCE_test_USER ?= project-name-branch
INSTANCE_test_HOST ?= $(INSTANCE_prod_HOST)
INSTANCE_test_OPTS ?= $(INSTANCE_prod_OPTS)

ifeq ($(MAKECMDGOALS),set-lagoon-secrets)
include .env.local.lagoon
endif

PHONY += lagoon-env
lagoon-env: ## Print Lagoon env variables
	$(call docker_compose_exec,printenv | grep LAGOON_)

PHONY += deploy-lagoon-%
deploy-lagoon-%: ## Deploy lagoon branch
	$(call step,Deploy Lagoon branch $*...\n)
	@lagoon -p $(LAGOON_PROJECT) deploy branch -b $*

PHONY += set-lagoon-secrets-%
set-lagoon-secrets-%: ## Set Lagoon secrets
		$(call step,Set Lagoon secrets on $*...\n)
		@$(foreach secret,$(LAGOON_SECRETS),$(call set_lagoon_secret,$(secret),$*))

PHONY += list-lagoon-vars-%
list-lagoon-vars-%: ## List variables from Lagoon
		$(call step,List variables from Lagoon on $*...\n)
		@lagoon -p $(LAGOON_PROJECT) list v --reveal -e $*

define set_lagoon_secret
printf "Setting secret on ${2}: %s = %s \n" "${1}" "${${1}}";
lagoon -p $(LAGOON_PROJECT) a v -N "${1}" -V "${${1}}" -S runtime -e ${2} --force || true;
endef
