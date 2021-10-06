# Changelog

## 2021-10-06.1
### Tunnistamo 2.0

Tunnistamo module has a major release to support openid_connect:2.0.

### Required actions
- Run composer require "drupal/helfi_tunnistamo:^2.0" -W in your project's root
- Run database updates: drush updb -y
- Delete old openid_connect clients: `rm conf/cmi/openid_connect.settings.facebook.yml conf/cmi/openid_connect.settings.generic.yml conf/cmi/openid_connect.settings.github.yml conf/cmi/openid_connect.settings.google.yml conf/cmi/openid_connect.settings.linkedin.yml conf/cmi/openid_connect.settings.tunnistamo.yml`
- Re-create tunnistamo client from /admin/config/people/openid-connect
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
