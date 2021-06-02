FROM ghcr.io/city-of-helsinki/drupal-docker-base:8.0

COPY / /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-progress --profile --prefer-dist --no-interaction --no-dev

# Copy deploy script
COPY docker/openshift/entrypoints/90-deploy.sh /entrypoints
RUN chmod +x /entrypoints/90-deploy.sh
