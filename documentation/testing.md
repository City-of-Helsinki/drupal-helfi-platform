# Testing

## Drupal tests

Tests can be run with `vendor/bin/phpunit -c /app/phpunit.xml.dist /path/to/test`.

## Existing site functional tests

By default, Drupal Core runs each test in a completely new Drupal instance, which is created from scratch for the test. In other words, none of your configuration and none of your content exists.

You can use the Drupal Test Traits (DTT) library to write tests that are run against an existing database.

### Installation

1. Install the library using Composer: `composer require weitzman/drupal-test-traits --dev`.
2. Make sure you have `tests/dtt/src/ExistingSite/` and `tests/dtt/src/ExistingSiteJavascript/` folders under your git root
3. Register the `Drupal\Tests\dtt\` namespace by adding this to your `composer.json`:
    ```json
     "autoload-dev": {
         "psr-4": {
             "Drupal\\Tests\\dtt\\": "tests/dtt/src"
         }
     }
    ```
4. Modify your `phpunit.xml.dist` file and add these environment variables inside the `<php>` section:
   ```xml
    <env name="DTT_MINK_DRIVER_ARGS" value='["chrome", {"chromeOptions":{"w3c": false }}, "http://chromium:4444"]'/>
    <env name="DTT_API_OPTIONS" value='{"socketTimeout": 360, "domWaitTimeout": 3600000}' />
    <env name="DTT_API_URL" value="http://chromium:9222"/>
    <env name="DTT_BASE_URL" value="http://app:8888"/>
    ```
   and these `<testsuite>` definitions under `<testsuites>` section:
    ```xml
    <testsuite name="existing-site">
      <directory>./tests/dtt/src/ExistingSite</directory>
      <directory>./public/modules/custom/*/tests/src/ExistingSite</directory>
      <directory>./public/modules/contrib/*/tests/src/ExistingSite</directory>
    </testsuite>
    <testsuite name="existing-site-javascript">
      <directory>./tests/dtt/src/ExistingSiteJavascript</directory>
      <directory>./public/modules/custom/*/tests/src/ExistingSiteJavascript</directory>
      <directory>./public/modules/contrib/*/tests/src/ExistingSiteJavascript</directory>
    </testsuite>
    ```

You can find a couple of example DTT tests in [drupal-helfi-etusivu](https://github.com/City-of-Helsinki/drupal-helfi-etusivu/tree/dev/tests/dtt/src) repository.

See https://gitlab.com/weitzman/drupal-test-traits for more information.

## Functional JavaScript tests

To run Functional JS tests, you must start your local environment with `testing` compose profile.

You can either modify your project's `.env` file and append `testing` to `COMPOSE_PROFILES` environment variable, or start the project with `COMPOSE_PROFILES=testing make up`.

In order for this to work, the `chromium` container must be able to connect back to `app` container, so `$SIMPLETEST_BASE_URL` must be something that `chromium` container can connect to.

For example `SIMPLETEST_BASE_URL=http://app:8888`, then start the Drush server with `drush rs $SIMPLETEST_BASE_URL --dns`.

## GitHub Actions

The app container must be started using `--hostname` option: 

```yaml
container:
  image: ghcr.io/city-of-helsinki/drupal-php-docker:${{ matrix.php-versions }}-alpine
  options: --hostname app
```

You have to override the `SIMPLETEST_BASE_URL` environment variable to use `app` hostname and start the Drush server using `--dns` flag:

```yaml
# .github/workflows/yourworkflow.yml
env:
  SIMPLETEST_BASE_URL: http://app:8888

jobs:
  test:
  steps:
    - name: Start services
      working-directory: ${{ env.DRUPAL_ROOT }}
      run: |
        vendor/bin/drush runserver $SIMPLETEST_BASE_URL --dns > /dev/null 2>&1 &
```

and `SIMPLETEST_BASE_URL` must use the `http://app` hostname.

### Functional JavaScript tests

At the moment, only Chromium 106 is supported due to `minkphp/MinkSelenium2Driver` not supporting Selenium 4 yet. See https://github.com/minkphp/MinkSelenium2Driver/pull/372.

Add `chromium` service to your actions yml:

```yaml
services:
  chromium:
    image: selenium/standalone-chrome:106.0
```

You can find a complete example in [City-of-Helsinki/drupal-module-helfi-navigation](https://github.com/City-of-Helsinki/drupal-module-helfi-navigation/blob/main/.github/workflows/ci.yml) module.
