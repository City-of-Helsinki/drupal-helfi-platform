# Changelog

## 2021-06-02.1

Added new Docker base images. NOTE: This change needs to be coordinated with IBM. Use [helsinkisolutionoffice](https://helsinkisolutionoffice.atlassian.net/secure/RapidBoard.jspa?rapidView=167) JIRA to create a ticket where you coordinate this change. For example: https://helsinkisolutionoffice.atlassian.net/browse/PLATTA-749

Available PHP versions: 8.0 and 7.4 (8.0 is used by default).

### Required actions
- Copy contents from platform's [docker/](docker/) directory to your repository's `docker/` folder
- Run `docker-compose build` and `make stop && make start` inside your project to update your local environment to use PHP 8.0.
- Update your repository's [.github/workflows/test.yml](.github/workflows/test.yml.dist) to run tests with PHP 8 ([commit](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/b85f16d7b8880dd4d2fe550bd7958308d408edfe)):
```diff
-image: ghcr.io/city-of-helsinki/drupal-php-docker:7.4
+image: ghcr.io/city-of-helsinki/drupal-php-docker:8.0
```
- Update your repository's [.env](.env) file to use correct image ([commit](https://github.com/City-of-Helsinki/drupal-helfi-platform/commit/29cc264c7c1521e94618c6afa84f628f3f9bc442)):
```diff
-DRUPAL_IMAGE=druidfi/drupal:7.4-web
+DRUPAL_IMAGE=druidfi/drupal:8.0-web
```

PHP version can be changed by modifying [docker/openshift/Dockerfile](docker/openshift/Dockerfile) and [docker/local/Dockerfile](docker/local/Dockerfile) and changing the version tag from 8.0 to 7.4 (not recommended).

## 2021-05-28.1

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
