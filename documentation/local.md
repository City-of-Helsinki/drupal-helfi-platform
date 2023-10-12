# Development environment

## Requirements
- Docker and Docker compose
- Make (BSD and GNU are supported)
- [Stonehenge](https://github.com/druidfi/stonehenge)

## Installation

- Clone the repository
- Go to Git root
- Start the project by running `make up`
- Run `make new` to install site from scratch using existing configuration
- Run `make fresh` to install site from existing `dump.sql` file or sync database from testing environment

## Usage

[Druidfi tools](https://github.com/druidfi/tools) library provides generic (`make`) commands to ease the development process.

You can list available commands by running `make help`. Run `make -n {command}` to see actions behind the given command.

## Docker compose

### Compose profiles

Compose profiles are used to only run services that are actually needed. For example, there is no reason to start `elasticsearch` or `artemis` containers if your project is not using them.

Modify the value of `COMPOSE_PROFILES` environment variable from `.env` file or start the project with `COMPOSE_RROFILES=your-profiles make up`.

### Customizing docker-compose.yml

The default `docker-compose.yml` file is intended to be updated automatically from upstream and should have no customizations.

You can create a `docker-compose.override.yml` file to add or override existing features.

See https://docs.docker.com/compose/multiple-compose-files/merge/ for more information.

## Installing site from existing database dump

By default, `make fresh` attempts to install site using `dump.sql` file in your Git root. If the `dump.sql` does not exist, the Database will be synced from your project's testing environment.

### Syncing database from testing environment

Your container must have `oc` tool build-in. This is included by default when using the default `hcr.io/city-of-helsinki/drupal-web` Docker images.

Add/modify `OC_PROJECT_NAME` environment variable in your project's `.env` file. The value should be the same as the name shown in OpenShift project list, for example `hki-kanslia-random-project`.

Make sure you have no `dump.sql` in your Git root and run `make fresh`. The command will sync database dump from your testing environment.

### Syncing database from production environment

The production environment can only be accessed through a VPN connection, meaning it's not possible to automatically sync the database from production environment.

If you need a production database, you can sync the database from production to testing environment and re-run `make fresh`. See
[Syncing databases between OpenShift environments](/documentation/openshift-db-sync.md) for more information.

The other option is to sync it using VPN and running the `oc` tool on your local machine. See:
- [OpenShift OC tool](/documentation/openshift-oc.md)
- [VPN instructions](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HELFI/pages/7535886371/Maintenance+VPN+Huoltoyhteys)
