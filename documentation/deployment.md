# Deployment

## Deployment tasks

The deployment tasks are run when a container is first started. Any subsequent containers will check the value of `$OPENSHIFT_BUILD_NAME` to determine if deployment tasks need to be run.

The tasks:

1. Run pre-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
2. Site is put into maintenance mode.
3. `drush deploy` is run. See https://www.drush.org/latest/deploycommand/ for documentation about `drush deploy`.
4. Run post-deployment hooks. See [Deploy hooks](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md).
5. Maintenance mode is disabled.

See the [deployment](/docker/openshift/entrypoints/20-deploy.sh) script for more up-to-date information.

_Important note_: Deployment tasks must be completed within 10 minutes.

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

Custom preflight checks can be added in generic `docker/openshift/preflight/all.preflight.php` file that is run on all environments, or environment-specific `docker/openshift/{env}.preflight.php` file.

The `{env}` is determined from `APP_ENV` environment variable. Usually `development`, `testing`, `staging` or `production`, so for example, testing environment checks should be placed in a file called `testing.preflight.php`.

You can create an exit condition by calling `preflight_failed('Error message');`. For example:
```php
<?php

if (my_failed_condition) {
  preflight_failed('My condition failed with an error code %s', $error_code);
}
```

