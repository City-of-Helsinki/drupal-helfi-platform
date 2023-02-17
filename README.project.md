# Your Drupal 9 project

Description of your project.

## Environments

Env | Branch | URL
--- | ------ | ---
development | * | http://yoursite.docker.so/
production | main | TBD

## Requirements

You need to have these applications installed to operate on all environments:

- [Docker](https://github.com/druidfi/guidelines/blob/master/docs/docker.md)
- [Stonehenge](https://github.com/druidfi/stonehenge)

## Create and start the environment

Start up the environment:

```bash
$ make up
```

Install the site from scratch or using existing configuration:

```bash
$ make new
```

Or sync the database from testing environment:

```bash
$ make fresh
```

To show all available commands:

```bash
$ make help
```

## Login to Drupal container

This will log you inside the app container:

```bash
$ make shell
```

## Documentation

See [documentatation](https://github.com/City-of-Helsinki/drupal-helfi-platform/tree/main/documentation).
