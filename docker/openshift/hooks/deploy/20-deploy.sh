#!/bin/sh

# Skip deployment script if ENV var is true
if [ "$SKIP_DEPLOY_SCRIPTS" = "true" ]; then
    echo "SKIP_DEPLOY_SCRIPTS is true. Skipping the steps."
    return
fi

source /init.sh

echo "Starting deploy: $(date)"

# Populate deploy ID so 20-deploy.sh is skipped.
# @todo Remove this once 20-deploy.sh is removed.
set_deploy_id $OPENSHIFT_BUILD_NAME

drush state:set system.maintenance_mode 1 --input-format=integer
# Run pre-deploy tasks.
# @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md
drush helfi:pre-deploy || true
# Run maintenance tasks (config import, database updates etc)
drush deploy
deploy_exit_code=$?
# Run post-deploy tasks.
# @see https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/documentation/deploy-hooks.md
drush helfi:post-deploy || true
# Disable maintenance mode
drush state:set system.maintenance_mode 0 --input-format=integer

# Exit with failure if drush deploy failed
if [ $deploy_exit_code -ne 0 ]; then
    exit 1
fi
