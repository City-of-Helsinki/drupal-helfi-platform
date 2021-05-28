# Changelog

## 2021-05-28.1

Added Admin toolbar (admin_toolbar) as a dependency for the helfi-platform-config.

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
