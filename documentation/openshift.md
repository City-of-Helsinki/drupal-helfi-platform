# OpenShift Drupal docker image

## Usage

The docker image is re-built on every deployment using project's [/docker/openshift/Dockerfile](/docker/openshift/Dockerfile). 

The codebase is built into image's `/var/www/html` folder using composer: `composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader` as `root` user. 

The container is run as random UID (non-root) user (like uid `10009900`) that has no write permissions to any files (except inside `/tmp` folder), meaning that files inside the container cannot be modified after the image is built.

See [City-of-Helsinki/drupal-docker-images](https://github.com/City-of-Helsinki/drupal-docker-images#openshift-drupal-docker-image) for more documentation about the underlying Docker image.

## Deployment tasks

The deployment tasks are run when a container is first started. Any subsequent containers will check the value of `$OPENSHIFT_BUILD_NAME` to determine if deployment tasks needs to be run.

The tasks:

1. Site is put into maintenance mode.
2. `drush deploy` is run. See https://www.drush.org/latest/deploycommand/ for documentation about `drush deploy`.
3. Maintenance mode is disabled.

See the [deployment](/docker/openshift/entrypoints/20-deploy.sh) script for more up-to-date information.

## Cron

Crons are run inside a separate cron container and use [docker/openshift/crons/base.sh](/docker/openshift/crons/base.sh) as an entrypoint.

The cron container is run using the same image as the Drupal container and should contain everything your normal container does.

The entrypoint is run only once and the container will die as soon as the "main" loop is finished, meaning that all scripts must be run inside an infinite loop. You can use `sleep XX` to define how often a certain task should be run.

Any scripts placed in repository's `docker/openshift/crons` folder will be copied automatically
to `/crons` folder inside the cron container, but won't be run automatically.

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

then add `exec "/crons/your-custom-cron-script.sh" &` to `docker/openshift/crons/base.sh` to run it.
