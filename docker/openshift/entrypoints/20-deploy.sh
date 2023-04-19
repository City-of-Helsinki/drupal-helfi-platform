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

function get_deploy_id {
  echo $(drush state:get deploy_id)
}

# Generate twig caches.
if [ ! -d "/tmp/twig" ]; then
  drush twig:compile || true
fi

# Attempt to set deploy ID in case this is the first deploy.
if [[ -z "$(get_deploy_id)" ]]; then
  drush state:set deploy_id $OPENSHIFT_BUILD_NAME
fi

# Exit early if deploy ID is still not set. This usually means either Redis or
# something else is down.
if [[ -z "$(get_deploy_id)" ]]; then
  echo "Could not fetch deploy ID. Something is probably wrong. Exiting early."
  exit 1
fi

# This script is run every time a container is spawned and certain environments might
# start more than one Drupal container. This is used to make sure we run deploy
# tasks only once per deploy.
if [ "$(get_deploy_id)" != "$OPENSHIFT_BUILD_NAME" ]; then
  drush state:set deploy_id $OPENSHIFT_BUILD_NAME
  # Put site in maintenance mode
  drush state:set system.maintenance_mode 1 --input-format=integer
  # Run helfi specific pre-deploy tasks. Allow this to fail in case
  # the environment is not using the 'helfi_api_base' module.
  # @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base
  drush helfi:pre-deploy || true
  # Run maintenance tasks (config import, database updates etc)
  drush deploy
  # Run helfi specific post deploy tasks. Allow this to fail in case
  # the environment is not using the 'helfi_api_base' module.
  # @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base
  drush helfi:post-deploy || true
  # Disable maintenance mode
  drush state:set system.maintenance_mode 0 --input-format=integer
fi
