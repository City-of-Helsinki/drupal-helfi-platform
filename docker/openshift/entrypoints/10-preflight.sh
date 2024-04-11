#!/bin/sh

source /init.sh

if [ -f "../docker/openshift/preflight/preflight.php" ]; then
  echo "Running preflight checks ..."
  if ! php ../docker/openshift/preflight/preflight.php; then
    exit 1
  fi
fi

