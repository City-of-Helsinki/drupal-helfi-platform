ARG DRUPAL_DOCKER_TAG=8.4
FROM ghcr.io/city-of-helsinki/drupal-docker-base:${DRUPAL_DOCKER_TAG}

COPY / /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader

# Copy custom entrypoints.
# @see https://github.com/City-of-Helsinki/drupal-docker-images/tree/main/openshift/drupal
RUN mkdir -p /crons /entrypoints /hooks
COPY docker/openshift/entrypoints/ /entrypoints
COPY docker/openshift/crons/ /crons
COPY docker/openshift/hooks/ /hooks
RUN chmod -R +x /entrypoints/* /hooks/* /crons/*

COPY docker/openshift/init.sh /
