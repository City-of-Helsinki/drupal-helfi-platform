#!/bin/bash

echo "Starting cron: $(date)"

# Base.sh will be run only once and the container will die as soon as the "main" loop
# is finished, meaning that all scripts must be run inside an infinite loop. You can use
# `sleep XX` to define how often certain task should be run.
#
# Any scripts placed in `docker/openshift/crons` folder will be copied automatically
# to `/crons` folder inside the cron container.
#
# Example cron:
# @code
# while true
# do
#   drush some-command
#   sleep 600
# done
# @endcode
#
# You can start any additional cron "daemons" here:
#
# exec "/crons/some-command.sh" &

while true
do
  echo "Running cron: $(date)\n"
  drush cron
  # Sleep for 6 hours.
  sleep 21600
done
