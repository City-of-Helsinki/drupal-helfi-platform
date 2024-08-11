#!/bin/bash

cd /var/www/html/public

function get_deploy_id {
  if [ ! -f "sites/default/files/deploy.id" ]; then
    touch sites/default/files/deploy.id
  fi
  echo $(cat sites/default/files/deploy.id)
}

function set_deploy_id {
  echo ${1} > sites/default/files/deploy.id
}

function output_error_message {
  echo ${1}
  php ../docker/openshift/notify.php "${1}" || true
}

function deployment_in_progress {
  if [ "$(get_deploy_id)" != "$OPENSHIFT_BUILD_NAME" ]; then
    return 0
  fi

  if [ "$(drush state:get system.maintenance_mode)" = "1" ]; then
    return 0
  fi

  return 1
}

function is_drupal_module_enabled {
  if drush pm-list --status=Enabled --filter=${1} --format=json | jq --exit-status '. == []' > /dev/null; then
    return 1
  fi

  return 0
}

if [ ! -d "sites/default/files" ]; then
  output_error_message "Container start error: Public file folder does not exist. Exiting early."
  exit 1
fi

# Make sure we have active Drupal configuration.
if [ ! -f "../conf/cmi/system.site.yml" ]; then
  output_error_message "Container start error: Codebase is not deployed properly. Exiting early."
  exit 1
fi

if [ ! -n "$OPENSHIFT_BUILD_NAME" ]; then
  output_error_message "Container start error: OPENSHIFT_BUILD_NAME is not defined. Exiting early."
  exit 1
fi

