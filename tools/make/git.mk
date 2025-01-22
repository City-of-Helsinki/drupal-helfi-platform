PHONY += copy-commit-message-script
copy-commit-message-script:
	@$(foreach name,$(shell find . -type d -name ".git" -exec dirname {} \; 2> /dev/null ),cp tools/commit-msg $(name)/.git/hooks && chmod +x $(name)/.git/hooks/commit-msg;)
