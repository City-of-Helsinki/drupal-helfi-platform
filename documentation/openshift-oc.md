# OpenShift OC tool

## Preparation

All `city-of-helsinki/drupal-web` images should contain `oc` binary. Call `make shell` to log into app container.

## Logging in

1. Obtain access token by visiting https://oauth-openshift.apps.arodevtest.hel.fi/oauth/token/request
2. Login using your token: `oc login --token=sha256~your-token --server=https://api.arodevtest.hel.fi:6443`

## Projects

- List available projects: `oc projects`
- Select project `oc project {project_name}`

## SSH

Select a project with `oc project {project_name}` then:

- List available pods: `oc get pods`
- SSH into pod (must be in Running state): `oc rsh pod-name`.

## SQL dump
Replace `pod-name` with a pod name from `oc get pods`. For example `drupal-xxx-something`.

1. Run `oc rsh pod-name drush sql:dump --result-file=/tmp/dump.sql` to dump the database.
2. Run `oc rsync pod-name:/tmp/dump.sql .` to copy the dump to your local machine.
3. Remove SQL dump: `oc rsh pod-name rm /tmp/dump.sql`.
