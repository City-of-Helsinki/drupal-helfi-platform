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

while true
do
  echo "Running cron: $(date)\n"
  drush cron
  # Sleep for 10 minutes.
  sleep 600
done
