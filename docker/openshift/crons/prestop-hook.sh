#!/bin/bash

for id in $(drush migrate:status --field=id); do drush migrate:stop $id; done
