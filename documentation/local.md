# Development environment

## Requirements
- Docker and Docker compose
- Make (BSD and GNU are supported)
- [Stonehenge](https://github.com/druidfi/stonehenge)

## Installation

- Make sure you have [Stonehenge](https://github.com/druidfi/stonehenge) up and running
- Clone the repository
- Go to Git root
- Start the project by running `make up`
- Run `make new` to install site from scratch using existing configuration
- Run `make fresh` to install site from existing `dump.sql` file or download the database dump from Azure Blob storage
- Optionally, run `make sync-local-settings` to download the project's shared `local.settings.php` from Azure Key Vault

## Usage

`Makefile` provides generic (`make`) commands to ease the development process.

You can list available commands by running `make help`. Run `make -n {command}` to see actions behind the given command.

## Docker compose

### Compose profiles

Compose profiles are used to only run services that are actually needed. For example, there is no reason to start `elasticsearch` or `artemis` containers if your project is not using them.

Modify the value of `COMPOSE_PROFILES` environment variable from `.env` file or start the project with `COMPOSE_RROFILES=your-profiles make up`.

Currently available profiles:
- `queue`: Apache Artemis queue service
- `search`: ElasticSearch service
- `varnish`: Varnish service. Provides `varnish-yourproject.docker.so` address.

### Customizing compose.yaml

The default `compose.yaml` file is intended to be updated automatically from upstream and should have no customizations.

You can create a `compose.override.yml` file to add or override existing features.

See https://docs.docker.com/compose/multiple-compose-files/merge/ for more information.

## Installing site from existing database dump

By default, `make fresh` attempts to install site using `dump.sql` file in your Git root. If the `dump.sql` does not exist, the database dump is downloaded from Azure Blob storage.

### Downloading database dump from Azure Blob storage

The database dump is created by your project's database pipeline and stored in Azure Blob storage. Set `AZURE_DUMP_CONTAINER` environment variable in your project's `.env` file to point to your project's blob container, for example `hki-database-blob-helfi-etusivu-test`.

Make sure you have no `dump.sql` in your Git root and run `make fresh`. The command runs Azure CLI in a Docker container and downloads the dump to `dump.sql`.

If you are not logged in, or your login has expired, you will be prompted to log in using a device code. If you are asked to select a tenant or subscription after logging in, select any hel.fi tenant. You can also log in beforehand with `make azure-login` and log out with `make azure-logout`. Azure CLI credentials are stored in `~/.azure-helfi` and shared between projects, so you only need to log in once.

If the command reports that the blob does not exist, run the database pipeline for your project to create it and try again.

The following variables can be overridden in `.env` (or `.env.local`) if needed:

| Variable                     | Default                                | Description                                  |
|------------------------------|----------------------------------------|----------------------------------------------|
| `AZURE_DUMP_CONTAINER`       | _(empty, required)_                    | Blob container holding the database dump     |
| `AZURE_DUMP_STORAGE_ACCOUNT` | `stplattaopsdevtest`                   | Storage account name                         |
| `AZURE_DUMP_BLOB`            | `testing.sql`                          | Name of the database dump blob               |
| `AZURE_DUMP_AUTH_MODE`       | `login`                                | Azure CLI `--auth-mode`                      |
| `AZURE_CLI_CONFIG_DIR`       | `$HOME/.azure-helfi`                   | Where Azure CLI credentials are stored       |
| `AZURE_CLI_IMAGE`            | `mcr.microsoft.com/azure-cli:latest`   | Azure CLI Docker image                       |

### Using production database

The production environment can only be accessed through a VPN connection, meaning it's not possible to easily sync the database from production environment.

If you need a production database, you can sync the database from production to testing environment, re-run the database pipeline and re-run `make fresh`. See
[Syncing databases between OpenShift environments](/documentation/openshift-db-sync.md) for more information.

The other option is to sync it using VPN and running the `oc` tool on your local machine. See:
- [VPN instructions](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HELFI/pages/7535886371/Maintenance+VPN+Huoltoyhteys)

## Syncing local settings from Azure Key Vault

Credentials and other settings needed for local development, such as API keys, can be shared through Azure Key Vault instead of copying them by hand. Each project's `public/sites/default/local.settings.php` is stored as a secret called `${PROJECT_NAME}-localsettingsphp` in the `hki-kanslia-drupaldev-kv` Key Vault. `PROJECT_NAME` is set in your project's `.env` file.

Run `make sync-local-settings` to download the file. If your `local.settings.php` has changes that are not in the secret, you will be asked before it's overwritten.

Run `make upload-local-settings` to save your current `local.settings.php` to the secret, for example after adding a new API key. Everyone who syncs the file gets the uploaded version, so you will be asked before an existing secret is replaced. Don't upload anything that only applies to your own environment.

The Key Vault policy requires secrets to expire within 90 days, so each upload sets the secret to expire after 90 days. An expired secret can still be downloaded. If the secret is up to date, `make upload-local-settings` asks whether you want to renew it for another 90 days.

Both commands use the same Azure CLI login as the database dump download, see [Downloading database dump from Azure Blob storage](#downloading-database-dump-from-azure-blob-storage). The file content is never printed.

The following variables can be overridden in `.env` (or `.env.local`) if needed:

| Variable                    | Default                                   | Description                           |
|-----------------------------|-------------------------------------------|---------------------------------------|
| `AZURE_KEY_VAULT`           | `hki-kanslia-drupaldev-kv`                | Key Vault holding the local settings  |
| `LOCAL_SETTINGS_SECRET`     | `${PROJECT_NAME}-localsettingsphp`        | Name of the secret                    |
| `LOCAL_SETTINGS_FILE`       | `public/sites/default/local.settings.php` | File to download to and upload from   |
| `LOCAL_SETTINGS_VALID_DAYS` | `90`                                      | Days until an uploaded secret expires |

## Testing production setup on local

Modify your `compose.yaml` file with something like:

```diff
diff --git a/compose.yaml b/compose.yaml
--- a/compose.yaml
+++ b/compose.yaml
@@ -1,14 +1,13 @@
 services:
   app:
     container_name: "${COMPOSE_PROJECT_NAME}-app"
-    image: "${DRUPAL_IMAGE}"
+    build:
+      context: .
+      dockerfile: docker/openshift/Dockerfile
     hostname: "${COMPOSE_PROJECT_NAME}"
-    volumes:
-      - .:/app:delegated
     depends_on:
       - db
     environment:
-      WEBROOT: /app/public
+      SIMPLETEST_DB: mysql://drupal:drupal@db:3306/drupal
+      OPENSHIFT_BUILD_NAME: some-build-id
```

Disable preflight checks in `docker/openshift/entrypoints/10-preflight.sh`:
```diff
diff --git a/docker/openshift/entrypoints/10-preflight.sh b/docker/openshift/entrypoints/10-preflight.sh
--- a/docker/openshift/entrypoints/10-preflight.sh
+++ b/docker/openshift/entrypoints/10-preflight.sh
@@ -5,7 +5,7 @@
 if [ -f "../docker/openshift/preflight/preflight.php" ]; then
   echo "Running preflight checks ..."
   if ! php ../docker/openshift/preflight/preflight.php; then
-    exit 1
   fi
 fi
```

Run `docker compose build` and `make stop up`.
