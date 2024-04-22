# Colors
NO_COLOR=\033[0m
CYAN=\033[36m
GREEN=\033[0;32m
RED=\033[0;31m
YELLOW=\033[0;33m

PHONY += help
help: ## List all make commands
	$(call step,Available make commands:\n)
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "${CYAN}%-30s${NO_COLOR} %s\n", $$1, $$2}' | sort

PHONY += lt
lt: ## Open localtunnel
ifeq ($(shell command -v lt || echo no),no)
	$(call warn,Install localtunnel with: ${YELLOW}npm install -g localtunnel${NO_COLOR})
else
	$(call step,Open localtunnel. Use CTRL+C to close localtunnel.\n)
	@lt --port 443 --subdomain $(COMPOSE_PROJECT_NAME) --local-https --allow-invalid-cert
endif

define dbg
	@printf "${GREEN}${1}:${NO_COLOR} ${2}\n"
endef

define group_step
	@printf "\n🌟 ${YELLOW}${1}${NO_COLOR}\n"
endef

define has
$(shell command -v ${1} > /dev/null 2>&1 && echo yes || echo no)
endef

define step
	@printf "\n⭐ ${YELLOW}${1}${NO_COLOR}\n"
endef

define sub_step
	@printf "\n   ${YELLOW}${1}${NO_COLOR}\n"
endef

define output
	@echo "${1}"
endef

define warn
	@printf "\n⚠️  ${1}\n\n"
endef

define copy
	$(call output,Copy $(1) >> $(2))
	@cp $(1) $(2)
endef

SED_Darwin := sed -i ''
SED_Linux := sed -i

define get_port
$(shell netstat -aln|awk '$$6=="LISTEN"{if($$4~"[.:][0-9]+$$"){split($$4,a,/[:.]/);p2=a[length(a)];p[p2]=1;}}END{for(i=3000;i<3999&&p[i];i++){};if(i==3999){exit 1};print i}')
endef

define replace_string
	$(call output,Replace $(1) >> $(2) in $(3))
	@$(SED_$(UNAME_S)) 's/$(1)/$(2)/g' $(3)
endef

define remove_string
	$(call output,Remove $(1) from $(2))
	@$(SED_$(UNAME_S)) '/$(1)/d' $(2)
endef

define run
	@${1} && printf "${2}\n" || printf "${RED}${3}${NO_COLOR}\n"
endef
