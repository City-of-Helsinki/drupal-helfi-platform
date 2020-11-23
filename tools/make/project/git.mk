PHONY += copy-commit-message-script
copy-commit-message-script:
	@$(foreach name,$(shell find public/modules/custom public/themes/custom -type d -name ".git" -print0 | xargs -0 dirname ) .,cp tools/commit-msg $(name)/.git/hooks;)
