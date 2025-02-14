# Deployment

The code is built into a read-only Docker image using [docker/openshift/Dockerfile](/docker/openshift/Dockerfile).

The deployment tasks are run in a job pod using the newly built Docker image. Once the deployment tasks are completed, the old Drupal containers will be replaced with new ones.

## Deployment tasks

The tasks:

1. Site is put into maintenance mode.
2. Run pre-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
3. `drush deploy` is run. See https://www.drush.org/latest/deploycommand/ for documentation about `drush deploy`.
4. Run post-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
5. Maintenance mode is disabled.

See [20-deploy.sh](/docker/openshift/deploy/20-deploy.sh) entrypoint for more up-to-date information.

## Handling failures

- todo

### Logging failures

In case of a failure, an error message is sent to a configured Sentry instance. See [notify.php](/docker/openshift/notify.php) script for more documentation.

In order to use this feature, you must define the following environment variables:

```bash
SENTRY_DSN=your-sentry-dsn
# Should be same as APP_ENV
SENTRY_ENVIRONMENT=environment
```

- See [Application logging](/documentation/logging.md#application-logs) for more documentation about Sentry.
- See https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HEL/pages/6785826654/Ymp+rist+muuttujien+lis+ys+Azure+DevOpsissa for more documentation (in Finnish) on how to define environment variables.

## Deployment preflight checks

Preflight checks can be used to run assertions before deployment tasks are run. If any preflight assertion fails, the deployment will be stopped and marked as failed.

The preflight check is triggered by [docker/openshift/entrypoints/10-preflight.sh](/docker/openshift/entrypoints/10-preflight.sh) script.

### Environment variable preflight check

You can define required environment variables in your `public/sites/default/*.settings.php` files:

```php
$preflight_checks['environmentVariables'][] = 'ENV_VARIABLE1';
$preflight_checks['environmentVariables'][] = 'ENV_VARIABLE2|ENV_VARIABLE3';
```

The pipe (`|`) character can be used as `or` condition. For example `ENV_VAR1|ENV_VAR2` will check if either `ENV_VAR1` or `ENV_VAR2` is defined.

### Custom preflight checks

Custom preflight checks can be added into a generic `docker/openshift/preflight/all.preflight.php` file that is run on all environments, or you can create an environment-specific `docker/openshift/{env}.preflight.php` file.

The `{env}` is determined from `APP_ENV` environment variable. Usually `development`, `testing`, `staging` or `production`, so for example, testing environment checks should be placed in a file called `testing.preflight.php`.

You can create an exit condition by calling `preflight_failed('Error message');`. For example:
```php
<?php

if (my_failed_condition) {
  preflight_failed('My condition failed with an error code %s', $error_code);
}
```

