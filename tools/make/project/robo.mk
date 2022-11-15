STONEHENGE_PATH ?= ${HOME}/stonehenge
PROJECT_DIR ?= ${GITHUB_WORKSPACE}
APP_PATH ?= /app
SITE_PREFIX ?=
DRUPAL_INSTALL_TARGET ?= install-drupal-from-dump

SETUP_ROBO_TARGETS :=
CI_POST_INSTALL_TARGETS :=

ifeq ($(DRUPAL_BUILD_FROM_SCRATCH),true)
	DRUPAL_INSTALL_TARGET := install-drupal
endif

ifeq ($(CI),true)
	SETUP_ROBO_TARGETS += install-stonehenge start-stonehenge set-permissions
	CI_POST_INSTALL_TARGETS += fix-files-permission
endif

SETUP_ROBO_TARGETS += up composer-install $(CI_POST_INSTALL_TARGETS) $(DRUPAL_INSTALL_TARGET) post-install-tasks

install-stonehenge: $(STONEHENGE_PATH)/.git

$(STONEHENGE_PATH)/.git:
	git clone -b 4.x https://github.com/druidfi/stonehenge.git $(STONEHENGE_PATH)

PHONY += start-stonehenge
start-stonehenge:
	cd $(STONEHENGE_PATH) && COMPOSE_FILE=docker-compose.yml make up

PHONY += install-drupal-ci-clean
install-drupal-ci:
	$(call docker_run_ci,app,drush si minimal -y)
	$(call docker_run_ci,app,drush cr)
	$(call docker_run_ci,app,composer config repositories.5 path /app/helfi_platform_config)
	$(call docker_run_ci,app,composer require drupal/helfi_platform_config -W)
	$(call docker_run_ci,app,set -e && drush en helfi_platform_config -y && for d in /app/public/modules/contrib/helfi_platform_config/helfi_features/*; do drush en -y \$$(basename "\$$d"); done)
	$(call docker_run_ci,app,drush enable:theme hdbt)
	$(call docker_run_ci,app,drush state:set locale.translation_last_checked 0)
	$(call docker_run_ci,app,drush locale:check)
	$(call docker_run_ci,app,drush locale:update)
	$(call docker_run_ci,app,drush cr)
	$(call docker_run_ci,app,drush helfi:locale-import helfi_platform_config)

PHONY += install-drupal
install-drupal:
	$(call docker_run_ci,app,drush si minimal -y)
	$(call docker_run_ci,app,drush cr)
	$(call docker_run_ci,app,drush si minimal --existing-config -y)
	$(call docker_run_ci,app,drush deploy)

PHONY += install-drupal-from-dump
install-drupal-from-dump:
	$(call docker_run_ci,app,drush sql-drop -y)
	$(call docker_run_ci,app,mysql --user=drupal --password=drupal --database=drupal --host=db --port=3306 -A < latest.sql)
	$(call docker_run_ci,app,drush deploy)

PHONY += post-install-tasks
post-install-tasks:
	$(call docker_run_ci,app,drush upwd helfi-admin Test_Automation)
	$(call docker_run_ci,app,drush en helfi_tpr helfi_example_content syslog -y)
	$(call docker_run_ci,app,drush helfi:migrate-fixture tpr_unit --publish)
	$(call docker_run_ci,app,drush helfi:migrate-fixture tpr_service --publish)
	$(call docker_run_ci,app,drush helfi:migrate-fixture tpr_errand_service --publish)
	$(call docker_run_ci,app,drush helfi:migrate-fixture tpr_service_channel --publish)
	$(call docker_run_ci,app,drush pmu editoria11y -y)

PHONY += save-dump
save-dump:
	$(call docker_run_ci,app,drush sql-dump --result-file=/app/latest.sql)

PHONY += robo-shell
robo-shell:
	@docker compose $(DOCKER_COMPOSE_FILES) exec robo sh

PHONY += set-permissions
set-permissions:
	chmod 777 /home/runner/.cache/composer -R
	chmod 777 -R $(PROJECT_DIR)

PHONY += fix-files-permission
fix-files-permission:
	mkdir $(PROJECT_DIR)public/sites/default/files -p && chmod 777 -R $(PROJECT_DIR)public/sites/default/files

define docker_run_ci
	docker compose exec -T $(1) sh -c "$(2)"
endef

PHONY += setup-robo
setup-robo: $(SETUP_ROBO_TARGETS)

PHONY += run-robo-tests
run-robo-tests:
	$(call docker_run_ci,robo,cd $(APP_PATH) && chmod +x run_all_tests.sh && CI_TA_PATH=$(APP_PATH) PREFIX=$(SITE_PREFIX) BASE_URL=$(DRUPAL_HOSTNAME) ./run_all_tests.sh)
