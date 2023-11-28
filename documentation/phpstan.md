# PHPStan

## Configuration

Copy `phpstan.neon` from the Drupal platform repository: https://github.com/City-of-Helsinki/drupal-helfi-platform/blob/main/phpstan.neon

## Usage

- Scan `public/modules/custom` and `public/themes/custom` folders: `vendor/bin/phpstan analyze`
- Scan a `helfi_*` contrib module: `vendor/bin/phpstan analyze -c public/modules/contrib/helfi_some_module public/modules/contrib/helfi_some_module`

## Scan code in GitHub Actions

Add something like to your project's action file:

```yaml
# .github/actions/test.yml
- name: Run phpstan
  run: vendor/bin/phpstan analyze
```

or if you're testing a contrib module:

```yaml
# .github/actions/ci.yml
- name: Run phpstan
  working-directory: ${{ env.DRUPAL_ROOT }}
  run: vendor/bin/phpstan analyze -c $MODULE_FOLDER/phpstan.neon $MODULE_FOLDER
```

See:
- https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/.github/workflows/ci.yml
- https://github.com/City-of-Helsinki/drupal-helfi-etusivu/blob/dev/.github/workflows/test.yml

## Custom entities

If your module defines custom entities, they must be exposed in `phpstan.neon` configuration. For example:

```yaml
parameters:
  drupal:
    entityMapping:
      global_menu:
        class: Drupal\helfi_global_navigation\Entity\GlobalMenu
        storage: Drupal\helfi_global_navigation\Entity\Storage\GlobalMenuStorage
```

You can omit `storage` in case your entity does not define a storage class.

## Ignore errors

You can either define ignored errors in your `phpstan.neon` file with something like:

```yaml
parameters:
  ignoreErrors:
    -
      message: '#^An error to ignore#'
      path: path/to/file.php
```

or with `// @phpstan-ignore-next-line` annotation.

See https://phpstan.org/user-guide/ignoring-errors for more information.
