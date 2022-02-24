#!/bin/bash

echo "Running TPR Migrations: $(date)"

function populate_variables {
  # Generate variables used to control which migrates needs
  # to be reset and which ones needs to be skipped based on
  # migrate status
  MIGRATE_STATUS=$(drush migrate:status --format=json)
  php ./docker/openshift/crons/migrate-status.php \
    tpr_unit,tpr_service,tpr_errand_service,tpr_service_channel \
    "$MIGRATE_STATUS" > /tmp/migrate-tpr-source.sh \
    $1

  # Contains variables:
  # - $RESET_STATUS
  # - $SKIP_MIGRATE
  # Both contains a space separated list of migrates
  source /tmp/migrate-tpr-source.sh
}

function reset_status {
  # Reset status of stuck migrations.
  for ID in $RESET_STATUS; do
    drush migrate:reset-status $ID
  done
}

function run_migrate {
  for ID in $SKIP_MIGRATE; do
    if [ "$ID" == "$1" ]; then
      return 1
    fi
  done
  return 0
}

# Populate variables for the first run after deploy and
# default migrate interval to 6 hours.
populate_variables 21600

while true
do
  # Reset stuck migrates.
  reset_status

  if run_migrate "tpr_unit"; then
    echo "Running TPR Unit migrate: $(date)"
    PARTIAL_MIGRATE=1 drush migrate:import tpr_unit
  fi
  if run_migrate "tpr_service"; then
    echo "Running TPR Service migrate: $(date)"
    PARTIAL_MIGRATE=1 drush migrate:import tpr_service
  fi
  if run_migrate "tpr_errand_service"; then
    echo "Running TPR Errand Service migrate: $(date)"
    PARTIAL_MIGRATE=1 drush migrate:import tpr_errand_service
  fi
  if run_migrate "tpr_service_channel"; then
    echo "Running TPR Service Channel migrate: $(date)"
    PARTIAL_MIGRATE=1 drush migrate:import tpr_service_channel
  fi
  # Reset migrate status if migrate has been running for more
  # than 12 hours.
  populate_variables 43200
  # Never skip migrate after first time.
  SKIP_MIGRATE=
  # Sleep for 6 hours.
  sleep 21600
done
