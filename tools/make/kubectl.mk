KUBECTL_BIN := $(shell command -v kubectl || echo no)
KUBECTL_NAMESPACE ?= foobar-namespace
KUBECTL_SHELL ?= sh
KUBECTL_EXEC_FLAGS ?= -n $(KUBECTL_NAMESPACE) -c $(KUBECTL_CONTAINER)
KUBECTL_WORKDIR ?= /app
KUBECTL_POD_SELECTOR ?= --field-selector=status.phase==Running

PHONY += kubectl-sync-db
kubectl-sync-db: ## Sync database from Kubernetes
ifeq ($(DUMP_SQL_EXISTS),no)
	$(eval POD := $(call kubectl_get_pod))
	$(call step,Get database dump from $(POD)...)
	$(call kubectl_exec_to_file,$(POD),drush sql-dump --structure-tables-key=common --extra-dump=--no-tablespaces,$(DUMP_SQL_FILENAME))
endif
	$(call step,Import local SQL dump...)
	$(call drush,sql-query --file=${DOCKER_PROJECT_ROOT}/$(DUMP_SQL_FILENAME))

PHONY += kubectl-sync-files-tar
kubectl-sync-files-tar: ## Sync files from Kubernetes using tar
	$(call step,Copy files from remote...)
	$(eval POD := $(call kubectl_get_pod))
	$(KUBECTL_BIN) exec $(KUBECTL_EXEC_FLAGS) $(POD) -- tar cf - $(SYNC_FILES_EXCLUDE) $(SYNC_FILES_PATH) | tar xfv - -C .

PHONY += kubectl-rsync-files
kubectl-rsync-files: FLAGS := -aurP --blocking-io
kubectl-rsync-files: REMOTE_PATH := $(KUBECTL_WORKDIR)/$(SYNC_FILES_PATH)/
kubectl-rsync-files: LOCAL_PATH := ./$(SYNC_FILES_PATH)/
kubectl-rsync-files: ## Sync files from Kubernetes using rsync
	$(call step,Sync files from remote...)
	$(eval POD := $(call kubectl_get_pod))
	rsync $(FLAGS) $(SYNC_FILES_EXCLUDE) --rsync-path=$(REMOTE_PATH) -e '$(KUBECTL_BIN) exec -i $(KUBECTL_EXEC_FLAGS) $(POD) -- env ' rsync: $(LOCAL_PATH)

PHONY += kubectl-shell
kubectl-shell: ## Open shell to Pod in Kubernetes
	$(eval POD := $(call kubectl_get_pod))
	$(KUBECTL_BIN) exec $(KUBECTL_EXEC_FLAGS) -ti $(POD) -- $(KUBECTL_SHELL)

define kubectl_exec
	$(KUBECTL_BIN) exec $(KUBECTL_EXEC_FLAGS) $(1) -- $(KUBECTL_SHELL) -c '$(2)'
endef

define kubectl_exec_to_file
	$(KUBECTL_BIN) exec $(KUBECTL_EXEC_FLAGS) $(1) -- $(KUBECTL_SHELL) -c '$(2)' > $(3)
endef

define kubectl_cp
	$(KUBECTL_BIN) cp $(KUBECTL_EXEC_FLAGS) $(1) $(2)
endef

define kubectl_get_pod
	$(shell $(KUBECTL_BIN) get pods -n $(KUBECTL_NAMESPACE) $(KUBECTL_POD_SELECTOR) -o jsonpath="{.items[0].metadata.name}")
endef
