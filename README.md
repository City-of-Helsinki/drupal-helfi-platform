# City-of-Helsinki/drupal-helfi-platform

This is a skeleton repository which will create a new Drupal 11 project for you and setup Docker based development environment with Stonehenge.

## Includes

- Drupal 11.x
- Drush 13.x
- Docker setup for development using [Stonehenge](https://github.com/druidfi/stonehenge)
- `make` commands to ease the development process
- Web root is `/public`
- Configuration is in `/conf/cmi`
- Custom modules are created in `/public/modules/custom`

## Documentation

See [documentation](/documentation).

## Get started

#### Requirements

- Docker and bash
- Make
- [Stonehenge](https://github.com/druidfi/stonehenge) up and running

#### Create a new project

```console
$ docker run --rm -v "$PWD":/app -w /app -u "$(id -u):$(id -g)" --entrypoint composer ghcr.io/city-of-helsinki/drupal-web:8.5 \
    create-project City-of-Helsinki/drupal-helfi-platform:dev-main yoursite --no-interaction --repository https://repository.drupal.hel.ninja/
$ cd yoursite
$ git init
```

#### Start the environment and install the site

```console
$ make up
$ make new
```

#### Run commands inside the container

Composer and Drush are run inside the `app` container:

```console
$ make shell
$ composer require drupal/some_module
$ drush cr
```

Composer refuses to run outside of the container.

#### Next steps

See [Development environment](/documentation/local.md) documentation.

## Contact

Slack: #helfi-drupal (http://helsinkicity.slack.com/)
