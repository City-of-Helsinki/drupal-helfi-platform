PHONY += init-project
init-project:
	@rm -f README.md renovate.json .github/workflows/ci.yml tools/make/project/init-project.mk
	@rm -rf documentation/
	@mv README.project.md README.md
	@composer config --unset scripts.post-create-project-cmd
