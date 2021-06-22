# City-of-Helsinki/drupal-helfi-platform

This is a skeleton repository which will create a new Drupal 9 project for you and setup Docker based development
environment with Stonehenge.

## Basic installation instructions (in Finnish)
https://github.com/City-of-Helsinki/drupal-helfi-platform/wiki/Hel.fi-platform-k%C3%A4ytt%C3%B6%C3%B6notto-hankkeissa

## Includes

- Drupal 9.0.x
- Drush 10.x
- Docker setup for development, see [docker-compose.yml](docker-compose.yml)
- [druidfi/tools](https://github.com/druidfi/tools)
- Web root is `/public`
- Configuration is in `/conf/cmi`
- Custom modules are created in `/public/modules/custom`

## Requirements

- PHP and Composer
- [Docker and Stonehenge](https://github.com/druidfi/guidelines/blob/master/docs/local_dev_env.md)

## Create a new project

### 1. using Composer

If you have PHP and Composer installed on your host (recommended):

```
$ composer create-project City-of-Helsinki/drupal-helfi-platform:dev-main yoursite --no-interaction \
    --repository https://repository.drupal.hel.ninja/
```

Or using Docker image:

```
mkdir yoursite && cd yoursite && \
docker run --rm -it -v $PWD:/app --env COMPOSER_MEMORY_LIMIT=-1 \
    druidfi/drupal:7.4-web \
    composer create-project City-of-Helsinki/drupal-helfi-platform:dev-main . --no-interaction \
    --repository https://repository.drupal.hel.ninja/
```

## Get started

Now you need to have Stonehenge up & running.

Start the development environment, build development codebase and install empty site with minimal profile:

```
$ make new
```

Now your site can can be accessed from https://yoursite.docker.so

## Next steps

You can run `make help` to list all available commands for you.

## Testing

Rename `.github/workflows/test.yml.dist` to `.github/workflows/test.yml` to enable automatic code checks.

## Automatic deploy on Azure

Rename all `azure-pipelines-*.yml.dist` files to `azure-pipelines-*.yml` and replace `drupal-REPLACEME` values to match your own project.

## OpenShift

See [docker/openshift](docker/openshift) for documentation.

## Contact

Slack: #helfi-drupal (http://helsinkicity.slack.com/)

Mail: helfi-drupal-aaaactuootjhcono73gc34rj2u@druid.slack.com
