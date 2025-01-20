	PHONY += init-project
	init-project:
			@rm CHANGELOG.md README.md renovate.json .github/workflows/ci.yml tools/make/project/spell.mk
			@rm -r documentation/
			@mv README.project.md README.md
			@composer config --unset scripts.post-create-project-cmd
			@git init && git add .
