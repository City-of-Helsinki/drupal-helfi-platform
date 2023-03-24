# City-of-Helsinki/drupal-helfi-platform

This is a skeleton repository which will create a new Drupal 9 project for you and setup Docker based development
environment with Stonehenge.

## Includes

- Drupal 9.x
- Drush 11.x
- Docker setup for development using [Stonehenge](https://github.com/druidfi/stonehenge)
- [druidfi/tools](https://github.com/druidfi/tools)
- Web root is `/public`
- Configuration is in `/conf/cmi`
- Custom modules are created in `/public/modules/custom`

## Documentation

See [documentation](/documentation).

## Changelog

See [CHANGELOG.md](/CHANGELOG.md)


## Get started

#### Requirements

- PHP and Composer
- [Docker and Stonehenge](https://github.com/druidfi/guidelines/blob/master/docs/local_dev_env.md)

#### Create a new project using composer

```console
$ composer create-project City-of-Helsinki/drupal-helfi-platform:dev-main yoursite --no-interaction --repository https://repository.drupal.hel.ninja/
```

Now you need to have Stonehenge up & running. See [Docker and Stonehenge](https://github.com/druidfi/guidelines/blob/master/docs/local_dev_env.md).

Start the development environment, build development codebase and install empty site with minimal profile:

```console
$ make new
```

Now your site can can be accessed from https://yoursite.docker.so

### Next steps

You can run `make help` to list all available commands for you.


## Contact

Slack: #helfi-drupal (http://helsinkicity.slack.com/)

Mail: `drupal@hel.fi`
