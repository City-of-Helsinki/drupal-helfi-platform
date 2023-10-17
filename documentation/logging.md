# Logging

## Container logs

Kibana is used for generic logging. See [Logging](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HELFI/pages/7610859671/Logging) on Confluence for technical documentation.

Drupal structures and sends all logs as JSON to Kibana using the logger service provided by Helfi API Base module. See [API Base - Logging](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/logging.md) for more information.

## Application logs

A service called [Sentry](https://docs.sentry.io/product/sentry-basics/) is used for application logging.

See [Sentry application information document](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HELFI/pages/7606763685/Sentry+-+Application+Information+Document+AID#Technical-solution) on Confluence for technical documentation.

### Usage
Install and enable the [Raven](https://www.drupal.org/project/raven) module:
- `composer require drupal/raven`
- `drush en raven`

### Configuration
> _IMPORTANT_: Testing and production uses different Sentry instances.

Sentry requires `SENTRY_ENVIRONMENT` and `SENTRY_DSN` environment variables. The value of `SENTRY_ENVIRONMENT` should be same as `APP_ENV`.

You can find the project specific `SENTRY_DSN` by going to Settings -> Projects -> Select a project -> Client keys (DSN) in Sentry.

Each project has their own team, so if you can't find your project, make sure to join the corresponding team by clicking the `Join a Team` button in the top right corner.

See this [Confluence page](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HELFI/pages/7606763685/Sentry+-+Application+Information+Document+AID#Technical-solution) for information on how to access Sentry service.
