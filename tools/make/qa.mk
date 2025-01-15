LINT_PHP_STANDARDS := Drupal,DrupalPractice
LINT_PHP_EXTENSIONS := inc,php,module,install,profile,theme

LINT_PATHS_PHP := /app/public/modules/custom
LINT_PATHS_PHP += /app/public/themes/custom

PHONY += fix
fix: fix-php ## Fix code style

PHONY += fix-php
fix-php:
	$(call step,Fix code using phpcbf ($(LINT_PATHS_PHP))...)
	$(call cs,phpcbf)

PHONY += lint
lint: lint-php ## Check code style

PHONY += lint-php
lint-php: ## Check code style for PHP files
	$(call step,Check code style for PHP files ($(LINT_PATHS_PHP))...)
	$(call cs,phpcs)

PHONY += test
test: test-phpunit ## Run tests

PHONY += test-phpunit
test-phpunit: ## Run PHPUnit tests
	$(call step,Run PHPUnit tests...)
	$(call docker_compose_exec,/app/vendor/bin/phpunit -c /app/phpunit.xml.dist $(1))

define cs
	$(call docker_compose_exec,vendor/bin/$(1) --standard=$(LINT_PHP_STANDARDS) --extensions=$(LINT_PHP_EXTENSIONS) --ignore=node_modules $(LINT_PATHS_PHP))
endef
