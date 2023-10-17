# City-of-Helsinki/drupal-helfi-platform

This is a skeleton repository which will create a new Drupal 9 project for you and setup Docker based development environment with Stonehenge.

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

#### Create a new project using composer

```console
$ composer create-project City-of-Helsinki/drupal-helfi-platform:dev-main yoursite --no-interaction --repository https://repository.drupal.hel.ninja/
```

#### Starting the development environment

See [Development environment](/documentation/local.md) documentation.

## Contact

Slack: #helfi-drupal (http://helsinkicity.slack.com/)
