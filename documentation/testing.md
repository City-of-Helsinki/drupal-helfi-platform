# Testing

## Drupal tests

Tests can be run with `vendor/bin/phpunit -c /app/phpunit.xml.dist /path/to/test`.

### Functional tests

Functional tests are run using build-in Drush webserver.

The server should be started automatically on local environment, in case it's not, you can run it with something like `drush rs $SIMPLETEST_BASE_URL --dns`.

### Functional JavaScript tests

To run Functional JS tests, you must start your local environment with `testing` compose profile.

You can either modify your project's `.env` file and append `testing` to `COMPOSE_PROFILES` environment variable, or start the project with `COMPOSE_PROFILES=testing make up`.

## CI tests

@todo
