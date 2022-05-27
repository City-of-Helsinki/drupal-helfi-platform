ARG DRUPAL_DOCKER_TAG=8.0
FROM ghcr.io/city-of-helsinki/drupal-docker-base:${DRUPAL_DOCKER_TAG}

COPY / /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-progress --profile --prefer-dist --no-interaction --no-dev --optimize-autoloader

# Update all packages to latest version if configured so.
RUN sh -c 'if [[ -n "$DRUPAL_FORCE_UPDATE_PACKAGES" ]] && [[ "$DRUPAL_FORCE_UPDATE_PACKAGES" -eq "1" ]]; then composer require $(drush helfi:composer:get-update-string) --with-all-dependencies; fi'

# Copy deploy script
COPY docker/openshift/entrypoints/20-deploy.sh /entrypoints
RUN chmod +x /entrypoints/20-deploy.sh

# Copy cron scripts
RUN mkdir /crons
COPY docker/openshift/crons/ /crons
RUN chmod +x /crons/*

# Copy nginx overrides.
COPY docker/openshift/custom.locations /etc/nginx/conf.d/custom.locations
