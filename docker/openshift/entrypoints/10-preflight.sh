#!/bin/sh

source /init.sh

if [ -f "../docker/openshift/preflight/preflight.php" ]; then
  echo "Running preflight checks ..."
  php ../docker/openshift/preflight/preflight.php
fi

