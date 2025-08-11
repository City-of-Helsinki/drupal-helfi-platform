ARG DRUPAL_DOCKER_TAG=8.3
FROM ghcr.io/city-of-helsinki/drupal-docker-base:${DRUPAL_DOCKER_TAG}

COPY / /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader

# Copy custom entrypoints.
# @see https://github.com/City-of-Helsinki/drupal-docker-images/tree/main/openshift/drupal
RUN mkdir -p /crons /entrypoints /hooks/deploy /hooks/db-replace
COPY docker/openshift/entrypoints/ /entrypoints
COPY docker/openshift/crons/ /crons
COPY docker/openshift/deploy /hooks/deploy
COPY docker/openshift/post-db-replace /hooks/db-replace
RUN chmod +x /entrypoints/* /hooks/deploy/* /crons/* /hooks/db-replace/*

COPY docker/openshift/init.sh /
