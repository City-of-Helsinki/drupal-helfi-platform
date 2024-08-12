#!/bin/bash

source /init.sh

echo "Starting cron: $(date)"

# You can add any additional cron "daemons" to docker/openshift/crons/ folder.
#
# Example:
# @code
# #!/bin/bash
# while true
# do
#   drush some-command
#   sleep 600
# done
# @endcode

for cron in /crons/*.sh; do
  # Skip legacy base.sh script if it exists.
  # Skip Kubernetes hooks that are stored in crons directory.
  if [[ "${cron##*/}" == "base.sh" ]] || [[ "${cron##*/}" == *-hook.sh ]]; then
    continue
  elif [[ -r "$cron" ]]; then
    echo "Starting $cron"
    exec "$cron" &
  fi
done

while true
do
  # Rudimentary process supervisor:
  # Waits for the next process to terminate. The parent
  # process is killed if any subprocess exists with failure.
  # OpenShift should then restart the cron pod.
  wait -n
  exit_code=$?
  if [[ "$exit_code" -ne 0 ]]; then
    output_error_message "Cron subprocess failed with exit code $exit_code"
    exit 1
  fi
done
