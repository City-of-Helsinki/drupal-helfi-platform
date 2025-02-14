ARG DRUPAL_DOCKER_TAG=8.3
FROM ghcr.io/city-of-helsinki/drupal-docker-base:${DRUPAL_DOCKER_TAG}

COPY / /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader

# Copy custom entrypoints.
# @see https://github.com/City-of-Helsinki/drupal-docker-images/tree/main/openshift/drupal
RUN mkdir -p /crons /entrypoints /deploy
COPY docker/openshift/entrypoints/ /entrypoints
COPY docker/openshift/crons/ /crons
COPY docker/openshift/deploy /deploy
RUN chmod +x /entrypoints/* /deploy/* /crons/*

COPY docker/openshift/init.sh /

# Copy nginx overrides.
COPY docker/openshift/custom.locations /etc/nginx/conf.d/custom.locations
