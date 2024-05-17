#!/bin/bash

# Skip deployment script if ENV var is true
if [ "$SKIP_DEPLOY_SCRIPTS" = "true" ]; then
    echo "SKIP_DEPLOY_SCRIPTS is true. Skipping the steps."
    return
fi

source /init.sh

function rollback_deployment {
  output_error_message "Deployment failed: ${1}"
  set_deploy_id ${2}
  exit 1
}

# Populate twig caches.
if [ ! -d "/tmp/twig" ]; then
  drush twig:compile || true
fi

# Capture the current deploy ID so we can roll back to previous version in case
# deployment fails.
CURRENT_DEPLOY_ID=$(get_deploy_id)

# This script is run every time a container is spawned and certain environments might
# start more than one Drupal container. This is used to make sure we run deploy
# tasks only once per deploy.
if [ "$CURRENT_DEPLOY_ID" != "$OPENSHIFT_BUILD_NAME" ]; then
  set_deploy_id $OPENSHIFT_BUILD_NAME

  if [ $? -ne 0 ]; then
    rollback_deployment "Failed to set deploy_id" $CURRENT_DEPLOY_ID
  fi
  # Put site in maintenance mode
  drush state:set system.maintenance_mode 1 --input-format=integer

  if [ $? -ne 0 ]; then
    rollback_deployment "Failed to enable maintenance_mode" $CURRENT_DEPLOY_ID
  fi
  # Run pre-deploy tasks.
  # @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md
  drush helfi:pre-deploy || true
  # Run maintenance tasks (config import, database updates etc)
  OUTPUT=$(sh -c '(drush deploy); exit $?' 2>&1)
  if [ $? -ne 0 ]; then
    rollback_deployment "drush deploy failed with {$?} exit code. ${OUTPUT}" $CURRENT_DEPLOY_ID
    exit 1
  fi
  # Run post-deploy tasks.
  # @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md
  drush helfi:post-deploy || true
  # Disable maintenance mode
  drush state:set system.maintenance_mode 0 --input-format=integer

  if [ $? -ne 0 ]; then
    rollback_deployment "Failed to disable maintenance_mode" $CURRENT_DEPLOY_ID
  fi
fi
