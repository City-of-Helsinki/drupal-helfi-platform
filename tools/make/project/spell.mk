PHONY += cast-spell
cast-spell: BASENAME := $(shell basename $(CURDIR))
cast-spell: ## Init Spell project
	$(call colorecho, "\nInit Spell project...")
	@sed -i -e 's|mysite|'"${BASENAME}"'|g' .env
ifeq ($(UNAME_S),Darwin)
	@sed -i '' '/composer.lock/d' .gitignore
else
	@sed -i '/composer.lock/d' .gitignore
endif
	@rm CHANGELOG.md README.md renovate.json .github/workflows/ci.yml tools/make/project/spell.mk
	@rm -r documentation/
	@mv README.project.md README.md
	@$(MAKE) self-update
	@composer config --unset scripts.post-create-project-cmd
	@git init && git add .
