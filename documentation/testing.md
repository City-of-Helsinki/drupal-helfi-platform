# Testing

## Drupal tests

Tests can be run with `vendor/bin/phpunit -c /app/phpunit.xml.dist /path/to/test`.

### Functional tests

Functional tests are run using build-in Drush webserver.

The server should be started automatically on local environment, in case it's not, you can run it with something like `drush rs $SIMPLETEST_BASE_URL`.

### Functional JavaScript tests

To run Functional JS tests, you must start your local environment with `testing` compose profile.

You can either modify your project's `.env` file and append `testing` to `COMPOSE_PROFILES` environment variable, or start the project with `COMPOSE_PROFILES=testing make up`.

In order for this to work, the `chromium` container must be able to connect back to `app` container, so `$SIMPLETEST_BASE_URL` must be something that `chromium` container can connect to.

For example `SIMPLETEST_BASE_URL=http://app:8888`, then start the Drush server with `drush rs $SIMPLETEST_BASE_URL --dns`.

## GitHub Actions

### Functional JavaScript tests

At the moment, only Chromium 106 is supported due to `minkphp/MinkSelenium2Driver` not supporting Selenium 4 yet. See https://github.com/minkphp/MinkSelenium2Driver/pull/372.

Add `chromium` service to your actions yml:

```yaml
services:
  chromium:
    image: selenium/standalone-chrome:106.0
```

The `chromium` service must be able to connect back to app container's Drush server, so the app container must be started using `--hostname app` option:

```yaml
container:
  image: ghcr.io/city-of-helsinki/drupal-php-docker:${{ matrix.php-versions }}-alpine
  options: --hostname app
```

You have to override the `SIMPLETEST_BASE_URL` environment variable to use `app` hostname:

```yaml
SIMPLETEST_BASE_URL: http://app:8888
```

and start the Drush server using `--dns` flag:
```yaml
- name: Start services
  working-directory: ${{ env.DRUPAL_ROOT }}
  run: |
    vendor/bin/drush runserver $SIMPLETEST_BASE_URL --dns > /dev/null 2>&1 &
```

You can find a complete example in [City-of-Helsinki/drupal-module-helfi-navigation](https://github.com/City-of-Helsinki/drupal-module-helfi-navigation/blob/main/.github/workflows/ci.yml) module.
