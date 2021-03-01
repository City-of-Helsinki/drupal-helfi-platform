# City-of-Helsinki/drupal-helfi-platform

This is a skeleton repository which will create a new Drupal 9 project for you and setup Docker based development
environment with Stonehenge.

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

Now your site can can be accessed from https://yoursite.docker.sh

## Next steps

Rename `.github/workflows/test.yml.dist` to `.github/workflows/test.yml` to enable code checks.

You can run `make help` to list all available commands for you.

## Additional information
### Issues with Paragraph module and admin theme
The platform does not have patches on the drupal core but there is a bug in the Claro-theme that causes paragraphs that
are placed inside paragraphs to have multiple drag handles and this then causes the admin UI to clutter. This issue is
listed in here: https://www.drupal.org/project/drupal/issues/3092181 and can be fixed by adding a patch to Drupal core.
We have also added piece of css to hide the redundant drag handles in hdbt_admin theme (https://github.com/City-of-Helsinki/drupal-hdbt-admin/pull/20/files#diff-721036acbbdc5d086b22422e09f5e86a878db3b416827e83cfd91d8a395ca801R53-R57), but if you still run into the
issue please patch your project using the code found from drupal.org.

## Contact

Slack: #helfi-drupal (http://helsinkicity.slack.com/)

Mail: helfi-drupal-aaaactuootjhcono73gc34rj2u@druid.slack.com
