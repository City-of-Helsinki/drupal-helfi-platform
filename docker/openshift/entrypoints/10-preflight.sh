#!/bin/sh

source /init.sh

if [ ! -d "../docker/openshift/preflight.php" ]; then
  exit 0
fi

php ../docker/openshift/preflight/preflight.php
