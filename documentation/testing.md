# Testing

## Drupal tests

Tests can be run with `vendor/bin/phpunit -c /app/phpunit.xml.dist /path/to/test`.

## Running tests on GitHub Actions

### Project tests

See [Platform repository](/.github/workflows/test.yml.dist) for an example.

## # Module tests

See [drupal/helfi_api_base](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/.github/workflows/ci.yml) module for an example.

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
    <env name="DTT_MINK_DRIVER_ARGS" value='["chrome", {"browserName":"chrome", "goog:chromeOptions":{"w3c": true, "args":["--no-sandbox","--ignore-certificate-errors", "--allow-insecure-localhost", "--headless", "--dns-prefetch-disable"]}}, "http://chromium:4444"]'/>
    <env name="DTT_API_OPTIONS" value='{"socketTimeout": 360, "domWaitTimeout": 3600000}' />
    <env name="DTT_API_URL" value="http://chromium:9222"/>
    <env name="DTT_BASE_URL" value="https://app"/>
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

Modify your `phpunit.xml.dist` and add `MINK_DRIVER_ARGS_WEBDRIVER` environment variable:

```xml
  <env name="MINK_DRIVER_ARGS_WEBDRIVER" value='["chrome", {"browserName":"chrome", "goog:chromeOptions":{"w3c": true, "args":["--no-sandbox", "--ignore-certificate-errors", "--allow-insecure-localhost", "--headless", "--dns-prefetch-disable"]}}, "http://chromium:4444"]' />
```

### Running functional javascript tests in local environment

1. Make sure your `docker-compose.yml` file contains `chromium` service and the `app` service has `SIMPLETEST_BASE_URL: "https://app"` environment variable:
    ```yaml
    services:
      app:
      chromium:
        image: selenium/standalone-chromium
        environment:
          SE_NODE_OVERRIDE_MAX_SESSIONS: "true"
          SE_NODE_MAX_SESSIONS: "16"
          SE_START_XVFB: "false"
          SE_START_VNC: "false"
          SE_SESSION_RETRY_INTERVAL: "1"
          SE_SESSION_REQUEST_TIMEOUT: "10"
        depends_on:
          - app
        networks:
          - internal
        profiles:
          - testing
    ```
2. Start your local environment with `testing` compose profile. You can either modify your project's `.env` file and append `testing` to `COMPOSE_PROFILES` environment variable, or start the project with `COMPOSE_PROFILES=testing make up`.

In order for this to work, the `chromium` container must be able to connect back to `app` container, so `$SIMPLETEST_BASE_URL` must be something that `chromium` container can connect to.

## Running functional javascript tests in GitHub Actions

1. The app container must be started using `--hostname` option:
    ```yaml
      container:
        image: ghcr.io/city-of-helsinki/drupal-web:8.3-dev
        options: --hostname app --user 1001
    ```

2. Add `chromium` service to your actions yml:
     ```yaml
    services:
      chromium:
        image: selenium/standalone-chromium
        env:
          SE_NODE_OVERRIDE_MAX_SESSIONS: "true"
          SE_NODE_MAX_SESSIONS: "16"
          SE_START_XVFB: "false"
          SE_START_VNC: "false"
          SE_SESSION_RETRY_INTERVAL: "1"
          SE_SESSION_REQUEST_TIMEOUT: "10"
      ```
3. You must start `nginx` and `php-fpm` services manually:
    ```yaml
    # .github/workflows/yourworkflow.yml
    jobs:
      tests:
        steps:
          - name: Start services
            env:
              WEBROOT: ${{ env.DRUPAL_ROOT }}/public
            run: entrypoint &
     ```

You can find a complete example in [City-of-Helsinki/drupal-module-helfi-navigation](https://github.com/City-of-Helsinki/drupal-module-helfi-navigation/blob/main/.github/workflows/ci.yml) module.

## Visual regression testing

### Setup

- Copy [backstop/](/backstop) folder to your project
- Rename [.github/workflows/visual-regression-test.yml.dist](/.github/workflows/visual-regression-testing.yml.dist) to `.github/workflows/visual-regression-test.yml`

You can add/modify test scenarios/viewports in [backstop/config.js](/backstop/config.js) file.

### Running on local

Generate reference images: `node backstop/backstop.js reference`.

Run tests against reference images: `node backstop/backstop.js test`.

### Running tests on GitHub Actions

The workflow works something like this:

1. The reference images are generated on commit to `dev` branch and stored as Actions artifact.
2. Opening a pull request will then download the artifact, extract the images as reference, run tests against said reference images and compare what has changed.
3. The HTML test result is uploaded to GitHub Pages, so you can visually preview the changes.
4. Merging the pull request will mark the changes as “approved” and generate new reference images.

Tests are run in Docker container using your project's `compose.yaml` file and [Stonehenge](https://github.com/druidfi/stonehenge).

### Setup GitHub Pages

Create an orphan `gh-pages` branch if you don't have one already: `git checkout --orphan gh-pages`. This will create a new branch with no parents, you can then clear the working directory with: `git rm --cached -r .`.

Create and commit an empty `.nojekyll` file. This will tell GitHub Pages to skip the build process since we're only deploying generated HTML content.

Go to your repository's Settings -> Pages and choose `gh-pages` branch from the `Branch` dropdown.

### Workflow permissions

You must grant "Read and write" permissions to the `GITHUB_TOKEN` so Actions can push to `gh-pages` branch and trigger the deployment.

Go to your repository's Settings -> Actions -> General -> Workflow permissions and choose "Read and write permissions".

### Cleaning up old test previews

Create `.github/workflows/visual-regression-cleanup.yml` file:

```yaml
name: Delete old BackstopJS preview pages
on:
  # This allows the workflow to be triggered manually from the Actions tab.
  workflow_dispatch:
  # Run once a day at 04:05.
  schedule:
    - cron: '5 4 * * *'

concurrency:
  group: visual-regression

jobs:
  visual-regression-cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: gh-pages

      - name: Setup Git user
        run: |
          git config --global user.name github-actions
          git config --global user.email github-actions@github.com

      - name: Remove stale preview pages
        env:
          GH_TOKEN: ${{ github.token }}
        # This will:
        # - Loop through all preview folders (pull/{{ number }}) and parse the pull request number
        # - Check if the pull request is still open using GitHub CLI tool.
        # - Remove the folder if the pull request is not open
        run: |
          for d in pull/*; do
            id=$(echo $d | cut -d / -f2)
            state=$(gh pr view $id --json state --jq .state)

            if [ "$state" != "OPEN" ]; then
              rm -r pull/$id
            fi
          done

          if [[ $(git status --porcelain) ]]; then
            git add .
            git commit -m 'Automated commit'
            git push
          fi
```
