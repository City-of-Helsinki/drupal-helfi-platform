#!/bin/bash

# Checking if a new deployment is in progress, as we should not run cron while deploying.
if [ ! -n "$OPENSHIFT_BUILD_NAME" ]; then
  echo "OPENSHIFT_BUILD_NAME is not defined. Exiting early."
  exit 1
fi

while [ "$(drush state:get deploy_id)" != "$OPENSHIFT_BUILD_NAME" ]
do
  echo "Current deploy_id $OPENSHIFT_BUILD_NAME not found in state. Probably a deployment is in progress - waiting for completion..."
  sleep 60
done

while [ "$(drush state:get system.maintenance_mode)" = "1" ]
do
  echo "Maintenance mode on. Probably a deployment is in progress - waiting for completion..."
  sleep 60
done

echo "Starting cron: $(date)"

# You can add any additional cron "daemons" here:
#
# exec "/crons/some-command.sh" &
#
# Example cron (docker/openshift/crons/some-command.sh):
# @code
# #!/bin/bash
# while true
# do
#   drush some-command
#   sleep 600
# done
# @endcode

# Uncomment this to enable TPR migration cron
#exec "/crons/migrate-tpr.sh" &
# Uncomment this to enable Varnish purge cron
#exec "/crons/purge-queue.sh" &
# Uncomment this to enable automatic translation updates.
# exec "/crons/update-translations.sh" &
# Uncomment this to enable content scheduler
# exec "/crons/content-scheduler.sh" &

while true
do
  echo "Running cron: $(date +'%Y-%m-%dT%H:%M:%S%:z')\n"
  drush cron
  # Sleep for 10 minutes.
  sleep 600
done
