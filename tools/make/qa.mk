TEST_TARGETS += test-phpunit
FIX_TARGETS :=
LINT_PHP_TARGETS :=

PHONY += fix
fix: ## Fix code style
	$(call step,Fix code...)
	$(call sub_step,Following targets will be run: $(FIX_TARGETS))
	@$(MAKE) $(FIX_TARGETS)

PHONY += lint
lint: lint-php lint-js ## Check code style

PHONY += lint-js
lint-js: DOCKER_NODE_IMG ?= node:8.16.0-alpine
lint-js: WD := /app
lint-js: ## Check code style for JS files
	$(call step,Install linters...)
	@docker run --rm -v "$(CURDIR)":$(WD):cached -w $(WD) $(DOCKER_NODE_IMG) yarn --cwd $(WEBROOT)/core install
	$(call step,Check code style for JS files: $(DRUPAL_LINT_PATHS))
	@docker run --rm -v "$(CURDIR)":$(WD):cached -w $(WD) $(DOCKER_NODE_IMG) \
		$(WEBROOT)/core/node_modules/eslint/bin/eslint.js --color --ignore-pattern '**/vendor/*' \
		--c ./$(WEBROOT)/core/.eslintrc.json --global nav,moment,responsiveNav:true $(LINT_PATHS_JS)

PHONY += lint-php
lint-php: ## Check code style for PHP files
	$(call step,Check code style for PHP files...)
	$(call sub_step,Following targets will be run: $(LINT_PHP_TARGETS))
	@$(MAKE) $(LINT_PHP_TARGETS)
	$(call test_result,lint-php,"[OK]")

PHONY += test
test: ## Run tests
	$(call group_step,Run test targets:${NO_COLOR} $(TEST_TARGETS)\n)
	@$(MAKE) $(TEST_TARGETS)
	$(call step,Tests completed.)

PHONY += test-phpunit
test-phpunit: TESTSUITES := unit,kernel,functional
test-phpunit: ## Run PHPUnit tests
	$(call step,Run PHPUnit tests...)
ifeq ($(CI),true)
	vendor/bin/phpunit -c phpunit.xml.dist --testsuite $(TESTSUITES)
else
	$(call docker_run_cmd,${DOCKER_PROJECT_ROOT}/vendor/bin/phpunit -c $(DOCKER_PROJECT_ROOT)/phpunit.xml.dist \
		--testsuite $(TESTSUITES))
endif
	$(call test_result,test-phpunit,"[OK]")

PHONY += test-phpunit-locally
test-phpunit-locally: TESTSUITES := unit,kernel,functional
test-phpunit-locally:
	@SIMPLETEST_BASE_URL=http://$(DRUPAL_HOSTNAME) SIMPLETEST_DB=mysql://$(DB_URL) \
    		vendor/bin/phpunit -c $(CURDIR)/phpunit.xml.dist --testsuite $(TESTSUITES)

define test_result
	@echo "\n${YELLOW}${1}:${NO_COLOR} ${GREEN}${2}${NO_COLOR}"
endef
