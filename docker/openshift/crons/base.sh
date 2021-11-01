#!/bin/bash

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

while true
do
  echo "Running cron: $(date)\n"
  drush cron
  # Sleep for 10 minutes.
  sleep 600
done
