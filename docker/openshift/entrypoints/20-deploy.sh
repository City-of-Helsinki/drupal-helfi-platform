#!/bin/bash

cd /var/www/html/public

# Make sure we have active Drupal configuration.
if [ ! -f "../conf/cmi/system.site.yml" ]; then
  echo "Codebase is not deployed properly. Exiting early."
  exit 1
fi

if [ ! -n "$OPENSHIFT_BUILD_NAME" ]; then
  echo "OPENSHIFT_BUILD_NAME is not defined. Exiting early."
  exit 1
fi

# Generate twig caches.
if [ ! -d "/tmp/twig" ]; then
  drush twig:compile || true
fi

# This script is run every time a container is spawned and certain environments might
# start more than one Drupal container. This is used to make sure we run deploy
# tasks only once per deploy.
if [ "$(drush state:get deploy_id)" != "$OPENSHIFT_BUILD_NAME" ]; then
  drush state:set deploy_id $OPENSHIFT_BUILD_NAME
  # Put site in maintenance mode during deploy
  drush state:set system.maintenance_mode 1 --input-format=integer
  # Run maintenance tasks (config import, database updates etc)
  drush deploy
  # Disable maintenance mode
  drush state:set system.maintenance_mode 0 --input-format=integer
fi
