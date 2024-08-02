#!/bin/bash

source /init.sh

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

# Enable drush cron
exec "/crons/cron.sh" &
# Uncomment this to enable TPR migration cron
#exec "/crons/migrate-tpr.sh" &
# Uncomment this to enable linked events migrations cron
#exec "/crons/linked-events.sh" &
# Uncomment this to enable Varnish purge cron
#exec "/crons/purge-queue.sh" &
# Uncomment this to enable automatic translation updates.
# exec "/crons/update-translations.sh" &
# Uncomment this to enable content scheduler
# exec "/crons/content-scheduler.sh" &

while true
do
  # Rudimentary process supervisor:
  # Waits for the next process to terminate. The parent
  # process is killed if any subprocess exists with failure.
  # OpenShift should then restart the cron pod.
  wait -n
  exit_code=$?
  if [[ "$exit_code" -ne 0 ]]; then
    output_error_message "Subprocess failed with exit code $exit_code"
    exit 1
  fi
done
