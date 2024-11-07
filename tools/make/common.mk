ARTIFACT_INCLUDE_EXISTS := $(shell test -f conf/artifact/include && echo yes || echo no)
ARTIFACT_EXCLUDE_EXISTS := $(shell test -f conf/artifact/exclude && echo yes || echo no)
ARTIFACT_CMD := tar -hczf artifact.tar.gz
DUMP_SQL_FILENAME ?= dump.sql
DUMP_SQL_EXISTS := $(shell test -f $(DUMP_SQL_FILENAME) && echo yes || echo no)
SSH_OPTS ?= -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
CLEAN_EXCLUDE := .idea $(DUMP_SQL_FILENAME) .env.local

ifeq ($(ARTIFACT_EXCLUDE_EXISTS),yes)
	ARTIFACT_CMD := $(ARTIFACT_CMD) --exclude-from=conf/artifact/exclude
endif

ifeq ($(ARTIFACT_INCLUDE_EXISTS),yes)
	ARTIFACT_CMD := $(ARTIFACT_CMD) --files-from=conf/artifact/include
else
	ARTIFACT_CMD := $(ARTIFACT_CMD) *
endif

PHONY += artifact
# This command can always be run on host
artifact: RUN_ON := host
artifact: ## Make tar.gz package from the current build
	$(call step,Create artifact...\n)
	@$(ARTIFACT_CMD)

PHONY += build
build: ## Build codebase(s)
	$(call group_step,Build ($(ENV)):${NO_COLOR} $(BUILD_TARGETS))
	@$(MAKE) $(BUILD_TARGETS) ENV=$(ENV)

PHONY += build-dev
build-dev: build

PHONY += build-testing
build-testing:
	@$(MAKE) build ENV=testing

PHONY += build-production
build-production:
	@$(MAKE) build ENV=production

PHONY += clean
clean: ## Cleanup
	$(call step,Cleanup loaded files...\n)
	@rm -rf vendor
	@git clean -fdx $(foreach item,$(CLEAN_EXCLUDE),-e $(item))

PHONY += self-update
self-update: ## Self-update makefiles from druidfi/tools
	$(call step,Update makefiles from druidfi/tools\n)
	@bash -c "$$(curl -fsSL $(UPDATE_SCRIPT_URL))"

PHONY += shell-%
shell-%: OPTS = $(INSTANCE_$*_OPTS)
shell-%: USER = $(INSTANCE_$*_USER)
shell-%: HOST = $(INSTANCE_$*_HOST)
shell-%: EXTRA = $(INSTANCE_$*_EXTRA)
shell-%: ## Login to remote instance
	ssh $(OPTS) $(USER)@$(HOST) $(EXTRA)

PHONY += sync
sync: ## Sync data from other environments
	$(call group_step,Sync:$(NO_COLOR) $(SYNC_TARGETS))
	@$(MAKE) $(SYNC_TARGETS) ENV=$(ENV)

PHONY += gh-download-dump
gh-download-dump: GH_FLAGS += $(if $(GH_ARTIFACT),-n $(GH_ARTIFACT),-n latest-dump)
gh-download-dump: GH_FLAGS += $(if $(GH_REPO),-R $(GH_REPO),)
gh-download-dump: ## Download database dump from repository artifacts
	$(call step,Download database dump from repository artifacts\n)
ifeq ($(DUMP_SQL_EXISTS),no)
	$(call run,gh run download $(strip $(GH_FLAGS)),Downloaded $(DUMP_SQL_FILENAME),Failed)
else
	@echo "There is already $(DUMP_SQL_FILENAME)"
endif
