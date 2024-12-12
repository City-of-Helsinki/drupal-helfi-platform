#!/bin/sh

set -e

if [ ! -n "$OC_PROJECT_NAME" ]; then
  echo "OC_PROJECT_NAME not set."
  exit 1;
fi

oc login --token=${1} --server=https://api.arodevtest.hel.fi:6443
oc project ${OC_PROJECT_NAME}

OC_POD_NAME=$(oc get pods -o name | grep drupal-cron | grep -v deploy)

if [ ! -n "$OC_POD_NAME" ]; then
  echo "Failed to parse pod name."
  exit 1
fi

oc rsh $OC_POD_NAME rm -f /tmp/dump.sql
oc rsh $OC_POD_NAME drush sql:dump --structure-tables-key=common \
  --extra-dump='--no-tablespaces --hex-blob' \
  --result-file=/tmp/dump.sql

oc rsync $OC_POD_NAME:/tmp/dump.sql /app
