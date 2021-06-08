# OpenShift docker container

See [City-of-Helsinki/drupal-docker-images](https://github.com/City-of-Helsinki/drupal-docker-images#openshift-drupal-docker-image) to see how this image is built.

## Cron

Crons are run inside a separate container and use [docker/openshift/crons/base.sh](crons/base.sh) as an entrypoint.

Base.sh will be run only once and the container will die as soon as the "main" loop is finished, meaning that all scripts must be run inside an infinite loop. You can use `sleep XX` to define how often certain task should be run.

Any scripts placed in repository's `docker/openshift/crons` folder will be copied automatically
to `/crons` folder inside the cron container, but won't be run automatically. See [docker/openshift/crons/base.sh](crons/base.sh) for more information about how to execute custom cron scripts.
