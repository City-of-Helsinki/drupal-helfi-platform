# OpenShift Drupal docker image

## Usage

The docker image is re-built on every deployment using project's [/docker/openshift/Dockerfile](/docker/openshift/Dockerfile).

The codebase is built into image's `/var/www/html` folder using composer: `composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader` as `root` user.

The container is run as random UID (non-root) user (like uid `10009900`) that has no write permissions to any files (except inside `/tmp` folder), meaning that files inside the container cannot be modified after the image is built.

See [City-of-Helsinki/drupal-docker-images](https://github.com/City-of-Helsinki/drupal-docker-images#openshift-drupal-docker-image) for more documentation about the underlying Docker image.

## Deployment preflight checks

Preflight checks can be used to run assertions before deployment tasks are run. If any preflight assertion fails, the deployment will be marked as failed.

See [preflight.php](/docker/openshift/preflight/preflight.php).

### Custom preflight checks

Create a new php file in `docker/openshift/preflight` folder and define `$preflight_checks['additionalFiles']` in your `public/sites/default/*.settings.php` file:

```php
// The filename/value is relative to docker/openshift/preflight folder.
$preflight_checks['additionalFiles'][] = 'your-custom-preflight.php';
```

You can create an exit condition by calling `preflight_failed('Error message');`. For example:
```php
<?php

if (my_failed_condition) {
  preflight_failed('My condition failed with and error code %s', $error_code);
}
```

### Defining required environment variables

You can define required environment variables in your `public/sites/default/*.settings.php` files:

```php
$preflight_checks['environmentVariables'][] = 'MY_REQUIRED_ENV_VARIABLE1';
$preflight_checks['environmentVariables'][] = 'MY_REQUIRED_ENV_VARIABLE2';
```

## Deployment tasks

The deployment tasks are run when a container is first started. Any subsequent containers will check the value of `$OPENSHIFT_BUILD_NAME` to determine if deployment tasks needs to be run.

The tasks:

1. Run pre-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
2. Site is put into maintenance mode.
3. `drush deploy` is run. See https://www.drush.org/latest/deploycommand/ for documentation about `drush deploy`.
4. Run post-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
5. Maintenance mode is disabled.

See the [deployment](/docker/openshift/entrypoints/20-deploy.sh) script for more up-to-date information.

### Handling failures

In case of a failure, an error message is sent to a configured Sentry instance. See [notify.php](/docker/openshift/notify.php) script for more documentation.

In order to use this feature, you must define the following environment variables:

```bash
SENTRY_DSN=your-sentry-dsn
# Should be same as APP_ENV
SENTRY_ENVIRONMENT=environment
```

See https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HEL/pages/6785826654/Ymp+rist+muuttujien+lis+ys+Azure+DevOpsissa for more documentation (in Finnish) on how to define environment variables.

## Cron

Crons are run inside a separate cron container and use [docker/openshift/crons/base.sh](/docker/openshift/crons/base.sh) as an entrypoint.

The cron container is run using the same image as the Drupal container and should contain everything your normal container does.

The entrypoint is run only once and the container will die as soon as the "main" loop is finished, meaning that all scripts must be run inside an infinite loop. You can use `sleep XX` to define how often a certain task should be run.

Any scripts placed in repository's `docker/openshift/crons` folder will be copied automatically
to `/crons` folder inside the cron container, but won't be run automatically.

### Running a custom cron

The cron script must contain something like:

```bash
#!/bin/bash

echo "Starting my custom cron script: $(date)"

while true
do
  echo "Running my custom cron script: $(date)"
  drush my_custom_command
  # Sleep for 60 seconds.
  sleep 60
done
```

then add `exec "/crons/your-custom-cron-script.sh" &` to `docker/openshift/crons/base.sh` to run it.
