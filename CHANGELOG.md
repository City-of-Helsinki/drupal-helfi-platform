# Changelog

## 2024-06-26 - Removed hal & rdf modules

HAL & RDF were deprecated just before D10 and were added to Drupal-platform's composer.json for compatibility reasons.
Both modules are now removed from drupal-platform and must be added to project's root composer.json if necessary.


## 2024-03-20 - Renamed docker-compose.yml file to compose.yaml

The `druidfi/tools` package now defaults to `compose.yaml` file instead of `docker-compose.yml`.

### Required actions
- Run `make self-update`
- Rename or symlink `docker-compose.yml` file to `compose.yaml`

## 2024-02-05 - Migrate from MariaDB to MySQL 8

Local and CI environments were migrated to use MySQL 8 to match the test/production environment.

**_IMPORTANT_**: This change will destroy your local database. Please make sure to backup your old database if you still wish to use it!

### Required actions

- Update the `docker-compose.yml` file from this repository
- Update `.github/workflows/` YAML files to use MySQL 8
- Update local docker images (`docker compose pull`)
- Re/start the project (`make stop && make up`)

### Optional actions

These steps are only required if you wish to save your old local database.

- Export the old database (`drush sql-dump --result-file=/app/dump.sql`)
- Update `docker-compose.yml` file from this repository
- Re/start the project `make stop && make up`
- Re-import the old database `$(drush sql:connect) < dump.sql`


## 2023-12-04.2 - Deployment changes

- Cron rollout now depends on Drupal rollout, meaning the Cron pod will no longer start before deployment is actually done
- `20-deploy.sh` now uses `public/sites/default/files/deploy.id` file to check if deployment tasks need to be run

### Required actions

Make sure your `docker/openshift/crons/base.sh` entrypoint **does not** have deployment checks anymore:

```bash
# Checking if a new deployment is in progress, as we should not run cron while deploying.
if [ ! -n "$OPENSHIFT_BUILD_NAME" ]; then
  echo "OPENSHIFT_BUILD_NAME is not defined. Exiting early."
  exit 1
fi

while [ "$(drush state:get deploy_id)" != "$OPENSHIFT_BUILD_NAME" ]
do
  echo "Current deploy_id $OPENSHIFT_BUILD_NAME not found in state. Probably a deployment is in progress - waiting for completion..."
  sleep 60
done

while [ "$(drush state:get system.maintenance_mode)" = "1" ]
do
  echo "Maintenance mode on. Probably a deployment is in progress - waiting for completion..."
  sleep 60
done
```

## 2023-12-04.1 - Preflight deployment checks

Added preflight deployment checks. See [Deployment documentation](/documentation/deployment.md#deployment-preflight-checks) for more information.

### Required actions

- Update your `docker/openshift/Dockerfile` file from this repository
- Copy `docker/openshift/init.sh`, `docker/entrypoints/10-preflight.sh` and `docker/openshift/preflight/preflight.php` files from this repository

### Required actions

## 2023-11-28

Added PHPStan documentation. See [documentation](/documentation/phpstan.md) for more information.

## 2023-10-31

Removed D9 support. If you still wish to use Drupal 9.x, see [9.x](https://github.com/City-of-Helsinki/drupal-helfi-platform/tree/9.x) branch.

## 2023-10-17

The upstream Docker image (`druidfi/drupal-web`) changed the default server name and port and may cause issues with `xdebug`.

The value was previously `app:8080` and is now `{projectname}.docker.so:443`.

### Required actions
- PHPStorm: Remove or update your existing PHP Servers. The name is now `{projectname}.docker.so` and the port is `443`

### Optional actions

Update your `docker-compose.yml` file to always populate `PHP_IDE_CONFIG` and `XDEBUG_CONFIG` environment variables:

```diff
diff --git a/docker-compose.yml b/docker-compose.yml
index c7dc6ba..350294d 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -21,6 +21,8 @@ services:
       # Optionally, you can add this to your default environments variables to enable or disable
       # xdebug by default (like /etc/environments, ~/.bashrc, or ~/.zshrc).
       XDEBUG_ENABLE: "${XDEBUG_ENABLE:-false}"
+      XDEBUG_CONFIG: "${XDEBUG_CONFIG:-}"
+      PHP_IDE_CONFIG: "${PHP_IDE_CONFIG:-serverName=${DRUPAL_HOSTNAME}}"
       # DOCKERHOST: host.docker.internal
       # Use drush server to run functional tests, so we don't have to care about
       # permission or SSL issues.
```

## 2023-10-07.2

Dropped support for PHP 8.0 Docker images. This change requires no actions.

## 2023-10-07.1

_NOTE_: This is only required if your project has functional javascript tests.

Local and CI Docker images no longer ship with chromium/chromium-driver packages.

### Required actions

- Update `docker-compose.yml`, `phpunit.xml.dist` files from this repository.
- Start your project using `testing` Docker compose profile. See [documentation](/documentation/local.md) for more information.
- Update your GitHub Actions .yml files. See [documentation/testing.md](/documentation/testing.md#functional-javascript-tests-1) for more information.

## 2023-09-27

base.sh cron has been updated with a feature which prevents running cron during deployment process.

### Required actions

Change should be manually added to the project's base.sh file. See [the actual change to copy](https://github.com/City-of-Helsinki/drupal-helfi-platform/pull/112/files)

## 2023-09-18

Added support for deleting old revisions automatically. See [documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/a81bbf291be5db7e9cc09cda3033da2398c91167/documentation/revisions.md).

## 2023-09-07.1

Added `$settings['deployment_identifier']` setting. This setting is used to determine if container
needs to be invalidated and rebuilt. This should fix the issue where deployment fails due to changed
service parameters in contrib modules.

### Required actions

Update `azure.settings.php` and `settings.php` files from this repository. Optionally, you can make the changes manually, see:
- https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/473e3534594e5f439d1d9bb1e14bf10285da1d11
- https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/3e368fb78d806c38274737e4eab65c9f20283707

## 2023-07-06.1

Removed branding navigation configuration as it is deprecated and not used any more.

## 2023-05-24.1

Added better deployment error handling and support for sending Slack messages for failed deployment.

See [OpenShift](/documentation/openshift.md#handling-failures) documentation for more information.

## 2023-05-23.1

Added project specific `make` commands and documentation how to use `node` container to build local assets.

See [Building assets](/documentation/build-assets.md) for more information.

## 2023-03-28.1

Scheduler cron key is now read from `DRUPAL_SCHEDULER_CRON_KEY` environment variable when set, and will fall back to `$settings['hash_salt']`.

The cron key is used by `scheduler` module to allow scheduler tasks to be triggered via HTTP API (`/scheduler/cron/{cron_key}`).

### Required actions

By default, `scheduler` is run using Drush ([docker/openshift/content-scheduler.sh](/docker/openshift/content-scheduler.sh)) and this change should require no actions.

## 2023-02-03.2

Enabled `READ-COMMITTED transaction isolation level` MySQL setting by default to improve performance and to minimize locking issues.

See https://www.drupal.org/docs/system-requirements/setting-the-mysql-transaction-isolation-level for more information.

## Required actions

- Run `drush helfi:tools:update-platform` to update your `settings.php` file.

## 2023-02-03.1

Added a GitHub Action to automatically create pull request from `dev` to `main` branch when a new commit is added to `dev` branch.

See [City-of-Helsinki/drupal-helfi-platform/blob/main/.github/workflows/auto-release-pr.yml.dist](https://github.com/City-of-Helsinki/drupal-helfi-platform/blob/main/.github/workflows/auto-release-pr.yml.dist)

## Required actions

To use this:
- Run `drush helfi:tools:update-platform` and rename the newly added `auto-release-pr.yml.dist` to `auto-release-pr.yml`

## 2023-01-18

Twig caches are now compiled on container start. This should considerably speed up the initial request after a new container is spawned.

See [docker/openshift/entrypoints/20-deploy.sh](/docker/openshift/entrypoints/20-deploy.sh).

## 2022-10-14

PHP 8.1 is now the default PHP version.

### Required actions
1. Run `drush helfi:tools:update-platform`. See [City-of-Helsinki/drupal-tools](https://github.com/City-of-Helsinki/drupal-tools) for instructions if the command does not exist.
2. Verify and test changes locally
3. Update `DRUPAL_DOCKER_TAG` value to `8.1` or `8.1-dev` on Azure DevOps (if set).

### Optional actions

Update guzzle to newer version to fix deprecation warnings:

1. Remove `drupal/core-recommended` package from your `composer.json`
2. Check if you have `weitzman/drupal-test-traits` package installed: `composer show weitzman/drupal-test-traits`. If it's installed you have to update it to version 2.0: `composer require --dev weitzman/drupal-test-traits:^2.0`.
3. Run `composer update`

## 2022-05-31.1

Added documentation of how to sync databases between OpenShift environments: [documentation/openshift-db-sync.md](/documentation/openshift-db-sync.md).

## 2022-05-19.1
### HDBT 3.0

The HDBT theme page layouts and blocks were overhauled and might cause BC breaks.
See changes: https://github.com/City-of-Helsinki/drupal-hdbt/releases/tag/3.0.0

### Required actions
1. Make sure your Drupal instance is up and running on latest dev/main branch
2. Update the HDBT and necessary modules by running: `composer require -W drupal/hdbt:^3.0; composer update -W drupal/helfi_platform_config drupal/helfi_tpr drupal/hdbt_admin`.
3. Run updates and export configuration. `make drush-updb drush-cr drush-cex`
4. Check that exported configuration is correct and commit the configuration changes to your repository.

## 2022-03-04.1
### Changed druidfi/db:mysql5.7-drupal docker image to druidfi/mariadb:10.5-drupal

This change was necessary since the base [mysql](https://hub.docker.com/_/mysql?tab=tags&page=1&name=5.7) image used to build `druidfi/db:mysql5.7-drupal` does not support Apple's M1 chip (arm64).

### Required actions
- Run `drush helfi:tools:update-platform` or update your `docker-compose.yml` [manually](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/b3b07018292638fc0b27d0e391774642718734fd#diff-e45e45baeda1c1e73482975a664062aa56f20c03dd9d64a827aba57775bed0d3).

## 2021-01-07.1
### Introducing drupal/helfi_drupal_tools package

The Drupal tools aims to provide a way to automatically sync updates from `drupal-helfi-platform`.

### Required actions
- Update your `composer.json` to use correct installer-path: https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/0359fd9d3f82f4d3e51eac5cb872b7ed0b5424c6#diff-d2ab9925cad7eac58e0ff4cc0d251a937ecf49e4b6bf57f8b95aab76648a9d34
- Install the package: `composer require drupal/helfi_drupal_tools`
- Run `drush helfi:tools:update-platform` to update changed files. This might require some manual actions, such as moving custom `settings.php` changes to `all.settings.php`.
- Commit or revert changed files.

## 2021-11-25.2
### Database sync from dev/testing to local

Added a support for database syncing from dev/testing environment to local.

### Required actions
- Copy contents from `drush/` folder to your project's repository
- Copy `tools/make/project/install.mk` and `.gitignore` files to your project's repository
- Add `OC_PROJECT_NAME=` environment variable to your `.env` file. The value should be your project's name in OpenShift
- Restart containers (`make stop && make up`)

Run `make fresh` to start the database sync.

### Optional actions

You can use `stage_file_proxy` module to serve files directly from your testing/dev environment without having to sync them to your local environment.

- Copy `settings.php` and add `STAGE_FILE_PROXY_ORIGIN` and `STAGE_FILE_PROXY_ORIGIN_DIR` environment variables to your `.env` file
- Install and enable `stage_file_proxy` module (`composer install drupal/stage_file_proxy`, `drush en stage_file_proxy`)

If you store files in azure blob storage then `STAGE_FILE_PROXY_ORIGIN` value should be something like `https://{storage-accountname}.core.windows.net` and `STAGE_FILE_PROXY_ORIGIN_DIR` should be your container's name, for example `dev`.

Otherwise `STAGE_FILE_PROXY_ORIGIN` should be an URL to your instance (`https://nginx-{project}-{env}.agw.arodevtest.hel.fi`) and `STAGE_FILE_PROXY_ORIGIN_DIR` is `sites/default/files`.

## 2021-11-25.1

### Pre-built drupal image that supports the new Apple M1 chip

### Required actions
- Remove `docker/local` folder (`rm -r docker/local`)
- Update value for `DRUPAL_IMAGE` in your `.env` file: `DRUPAL_IMAGE=ghcr.io/city-of-helsinki/drupal-web:8.0`
- Copy `docker-compose.yml` to your project's repository

## 2021-10-06.1
### Tunnistamo 2.0

Tunnistamo module has a major release to support openid_connect:2.0.

### Required actions
- Run `composer require "drupal/helfi_tunnistamo:^2.0" -W` in your project's root
- Run database updates: `drush updb -y`
- Delete old openid_connect clients: `rm conf/cmi/openid_connect.settings.facebook.yml conf/cmi/openid_connect.settings.generic.yml conf/cmi/openid_connect.settings.github.yml conf/cmi/openid_connect.settings.google.yml conf/cmi/openid_connect.settings.linkedin.yml conf/cmi/openid_connect.settings.tunnistamo.yml`
- Re-create tunnistamo client from `/admin/config/people/openid-connect`
- Update any settings.php overrides (`settings` key was changed to `client`), for example:  `$config['openid_connect.settings.tunnistamo']['settings']['is_production']` should now be `$config['openid_connect.client.tunnistamo']['settings']['is_production']`.

## 2021-09-16.1
### HELfi Platform Config 2.0

Update/install instructions for:
* drupal-helfi-platform-config 2.0.0

### Required actions
1. Install the site with your current configuration by running either `make new` or `make fresh`.
2. When the site is up and running, run `composer require drupal/helfi_platform_config:^2.0 --with-all-dependencies` to retrieve the new version of HELfi Platform config.
3. Run updates and export the configurations by running `make drush-updb drush-cr drush-cex`.
4. Go through configuration changes from `/conf/cmi/` and revert/modify any changes what will override your customised configurations.
5. Commit the changes to your repository.

## 2021-09-14.1
### Run deploy tasks only once per deploy

At the moment the deploy script is run every time a container replica is started. This can lead to a race condition when multiple containers are running deploy script at the same time, corrupting the entire configuration stack.

### Required actions
Replace your existing `docker/openshift/entrypoints/20-deploy.sh` with the updated one from this repository.

## 2021-08-12.1
### Easy breadcrumb 2.0

Update/install instructions for:
* drupal-helfi-platform-config 1.3.0

1. Update the HELfi platform config module by running: `composer require drupal/helfi_platform_config:1.3.0 --with-all-dependencies`.
2. Update your current Easy breadcrumb configuration file by copying the default settings file from `/public/modules/contrib/helfi_platform_config/features/helfi_base_config/config/install/easy_breadcrumb.settings.yml` to `/conf/cmi`. Do not forget to change any previously made changes to what was made to the file.
3. Commit the configurations changes to your repository.

## 2021-06-09.1
### OpenShift deploy script fix

Deploy script was previously meant to be run after nginx process was started, causing it to never run. This should be fixed now.

### Required actions
You can either remove entire `docker/openshift` folder and replace it with `docker/openshift` folder from this repository or:

1. Remove `docker/openshift/entrypoints/90-deploy.sh` file from your repository and replace it with `docker/openshift/entrypoints/20-deploy.sh` from platform's repository.
2. Modify `docker/openshift/Dockerfile` file and change lines containing `90-deploy.sh` to `20-deploy.sh`.

## 2021-06-08.1
### Cron support on OpenShift

Added support to run crons on OpenShift environment. See [docker/openshift/README.md](docker/openshift/README.md#cron) for more information.

### Required actions

- Copy contents from [docker/openshift](docker/openshift) folder to your repository's `docker/openshift` folder.
- This change requires actions from IBM. Use [helsinkisolutionoffice](https://helsinkisolutionoffice.atlassian.net/secure/RapidBoard.jspa?rapidView=167) JIRA to create a ticket labeled `Drupal cron support: {project name}` and assign it to your project's EPIC.

## 2021-06-07.2
### Remote video paragraph

Update/install instructions for:
* drupal-hdbt 1.3.5
* drupal-helfi-platform-config 1.2.6

1. `composer update` // Update dependencies.
2. `make shell` // Log in to shell
3. `drush features:import helfi_content -y` // Revert the Helfi content configuration feature.
4. Exit shell.
5. `make drush-cr drush-cex` // Rebuild caches, Export configurations.
6. Check that the configuration changes hasn’t overridden any of your custom modifications.
7. Commit the configurations changes to your repository.


## 2021-06-07.1
### Branding navigation

Update/install instructions for:
* drupal-hdbt 1.3.4
* drupal-helfi-platform-config 1.2.5

1. `composer update` // Update dependencies.
2. `make shell` // Log in to shell
3. `drush features:import helfi_base_config -y` // Revert the Helfi base configuration feature.
4. Exit shell.
5. `make drush-updb drush-cr drush-cex` // Run updates; Update theme blocks. ( hdbt_content 9001 ), Rebuild caches, Export configurations.
6. Check that the configuration changes hasn't overridden any of your custom modifications.
7. Commit the configurations changes to your repository.


## 2021-06-03.1
### Stonehenge update

Updated Stonehenge to 3.x version. *IMPORTANT*: This contains backward incompatible changes and requires manual actions.

Stonehenge 3.x changed the default domain from `*.docker.sh` to `*.docker.so`.

To update any existing project to use Stonehenge 3.x:

- Go to your stonehenge installation folder and run `git pull && git checkout 3.x`
- Run `make down && make up` (in stonehenge's installation folder)
- Update your project's `.env` and `README.md` with new `*.docker.so` domain
- Restart project's docker containers (`make stop && make up`)

## 2021-06-02.1
### New Docker base images

Added new Docker base images. NOTE: This change needs to be coordinated with IBM. Use [helsinkisolutionoffice](https://helsinkisolutionoffice.atlassian.net/secure/RapidBoard.jspa?rapidView=167) JIRA to create a ticket where you coordinate this change. For example: https://helsinkisolutionoffice.atlassian.net/browse/PLATTA-749

Available PHP versions: 8.0 and 7.4 (8.0 is used by default).

### Required actions
- Copy contents from platform's [docker/](docker/) directory to your repository's `docker/` folder
- Update your repository's [.env](.env) file to use correct image ([commit](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/29cc264c7c1521e94618c6afa84f628f3f9bc442)):
```diff
-DRUPAL_IMAGE=druidfi/drupal:7.4-web
+DRUPAL_IMAGE=druidfi/drupal:8.0-web
```
- Run `docker-compose build` and `make stop && make start` inside your project to update your local environment to use PHP 8.0.
- Update your repository's [.github/workflows/test.yml](.github/workflows/test.yml.dist) to run tests with PHP 8 ([commit](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/b85f16d7b8880dd4d2fe550bd7958308d408edfe)):
```diff
-image: ghcr.io/city-of-helsinki/drupal-php-docker:7.4
+image: ghcr.io/city-of-helsinki/drupal-php-docker:8.0
```

PHP version can be changed by modifying [docker/openshift/Dockerfile](docker/openshift/Dockerfile) and [docker/local/Dockerfile](docker/local/Dockerfile) and changing the version tag from 8.0 to 7.4 (not recommended).

## 2021-05-28.1
### Admin toolbar

Added Admin toolbar (`admin_toolbar`) as a dependency for the helfi-platform-config.

### Required actions
- In case of an error `"Unable to install HELfi Base config module since it requires the Admin Toolbar Extra Tools, Configuration replace, Field group modules."`
    - Enable the modules manually, export the configuration and commit the changes to your repository. `drush en -y admin_toolbar_tools config_replace field_group && drush cex -y`

## 2021-05-25.1

Converted `hdbt` and `hdbt_admin` to be `drupal-themes`s instead of `drupal-custom-themes`s, meaning that they will be installed inside `themes/contrib` folder from now on.

You can update existing themes with `composer update drupal/hdbt` and `composer update drupal/hdbt_admin` and then run `drush cr`.

### Required actions
- Update paths on `conf/cmi/select2_icon.settings.yml` to point to `/themes/contrib/hdbt/` instead of the current `/themes/custom/hdbt/`.

## 2021-05-21.1

Converted all `helfi_` to be `drupal-module`s instead of `drupal-custom-module`s, meaning that they will be installed inside `modules/contrib` folder from now on.

You can update existing modules with `composer update drupal/helfi_*` and then run `drush cr`.

### Required actions
- Replace your `phpunit.xml.dist` with [updated one](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/593b4f767bc903831a59bd732d550e7f909f7b21#diff-e35810879ec42bdd81797b3ccb72f6de28a8b4a0e3bfdba43183e133e866b892).

## 2021-05-12.1

Excluded all `helfi_` prefixed modules from phpunit tests (see phpunit.xml.dist) by default. Use `phpunit.platform.xml` (`vendor/bin/phpunit -c phpunit.platform.xml`) to run ALL tests, including custom helfi modules.
