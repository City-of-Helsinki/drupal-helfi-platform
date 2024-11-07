# OpenShift Drupal docker image

## Usage

The docker image is re-built on every deployment using project's [/docker/openshift/Dockerfile](/docker/openshift/Dockerfile).

The codebase is built into image's `/var/www/html` folder using composer: `composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader` as `root` user.

The container is run as random UID (non-root) user (like uid `10009900`) that has no write permissions to any files (except inside `/tmp` folder), meaning that files inside the container cannot be modified after the image is built.

See [City-of-Helsinki/drupal-docker-images](https://github.com/City-of-Helsinki/drupal-docker-images#openshift-drupal-docker-image) for more documentation about the underlying Docker image.

## Cron

Crons are run inside a separate cron container and use [docker/openshift/cron-entrypoint.sh](/docker/openshift/cron-entrypoint.sh) as an entrypoint.

The cron container is run using the same image as the Drupal container and should contain everything your normal container does.

Any scripts placed in repository's `docker/openshift/crons` folder will be copied automatically to `/crons` folder inside the cron container. The entrypoint executes all scripts in `/crons` directory and will die if any of the scripts fail, so that if any of the scripts fail, the whole container exits with a failure. OpenShift automatically restarts failed cron container.

The scripts are not restarted if they exit gracefully, meaning they must be run inside an infinite loop. You can use `sleep XX` to define how often a certain task should be run.

### Running a custom cron

The cron script must contain something like:

```bash
#!/bin/bash

echo "Starting my custom cron script: $(date)"

while true
do
  echo "Running my custom cron script: $(date)"
  drush my_custom_command
  # Sleep for 60 seconds.
  sleep 60
done
```

The scripts should check any preconditions and exit gracefully if they should not be run in some environments. For example, you can use `is_drupal_module_enabled` function from [`docker/openshift/init.sh`](/docker/openshift/init.sh) and exit if required modules are not enabled.

```bash
#!/bin/bash

source /init.sh

if ! is_drupal_module_enabled "helfi_react_search"; then
  exit 0
fi

...
```
