ANSIBLE_ROLES_PATH ?= ansible/roles
ANSIBLE_CHECK_ROLE ?= geerlingguy.docker
ANSIBLE_PLAYBOOK ?= ansible-playbook
ANSIBLE_PROVISION ?= ansible/provision.yml
ANSIBLE_REQUIREMENTS ?= ansible/requirements.yml
ANSIBLE_FLAGS ?=

PHONY += provision
provision: $(ANSIBLE_ROLES_PATH)/$(ANSIBLE_CHECK_ROLE) ## Make provisioning
	$(call step,Ansible: Make dry run on provisioning...\n)
	@$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PROVISION) $(ANSIBLE_FLAGS)

PHONY += provision-%
provision-%: $(ANSIBLE_ROLES_PATH)/$(ANSIBLE_CHECK_ROLE) ## Make provisioning by tag
	$(call step,Ansible: Make provisioning by tag "$*"...\n)
	@$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PROVISION) --tags="$*" $(ANSIBLE_FLAGS)

PHONY += provision-dry-run
provision-dry-run: $(ANSIBLE_ROLES_PATH)/$(ANSIBLE_CHECK_ROLE) ## Make dry run on provisioning
	$(call step,Ansible: Make dry run on provisioning...\n)
	@$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PROVISION) $(ANSIBLE_FLAGS) --check

PHONY += ansible-install-roles
ansible-install-roles: ## Install Ansible roles
	$(call step,Ansible: Install Ansible roles...\n)
	@ansible-galaxy install -r $(ANSIBLE_REQUIREMENTS) -p $(ANSIBLE_ROLES_PATH)

PHONY += ansible-update-roles
ansible-update-roles: ## Update Ansible roles
	$(call step,Ansible: Update Ansible roles...\n)
	@ansible-galaxy remove --roles-path=$(ANSIBLE_ROLES_PATH) $(shell find $(ANSIBLE_ROLES_PATH) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;) || true
	@ansible-galaxy install --force-with-deps --role-file=$(ANSIBLE_REQUIREMENTS) --roles-path=$(ANSIBLE_ROLES_PATH)

$(ANSIBLE_ROLES_PATH)/$(ANSIBLE_CHECK_ROLE):
	@$(MAKE) ansible-install-roles
