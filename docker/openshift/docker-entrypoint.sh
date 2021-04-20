#!/usr/bin/env bash

echo "Copy Drupal to the root folder of the web server"
# copy files to Azure Disk after the container has started and volumes have been mounted
rsync -vah "/opt/drupal/public/" "/var/www/html/public/" --exclude="web/sites/default/files" --delete
rsync -vah "/opt/drupal/vendor/" "/var/www/html/vendor/" --delete
rsync -vah "/opt/drupal/conf/" "/var/www/html/conf/" --delete
rsync -vah "/opt/drupal/drush/" "/var/www/html/drush/" --delete
cp /opt/drupal/composer.* /var/www/html/
# copy /opt/drupal/drush (and other files & folders) to /var/www/html as they become necessary

# mount permanent storage (public_files)
ln -s /var/www/public_files /var/www/html/public/sites/default/files

echo "Set cron key"
if [[ ! -z "${DRUPAL_CRON_KEY}" ]]; then
    echo ${DRUPAL_CRON_KEY}
    drush sset system.cron_key ${DRUPAL_CRON_KEY}
fi

echo "To install Drupal for the first time (clears database), execute"
echo "drush site:install --existing-config"
echo "in /var/www/html/public via the terminal"
cd /var/www/html/public && drush cr && drush updb -y && drush cim -y
# Allow locale-import to fail.
cd /var/www/html/public && drush helfi:locale-import helfi_platform_config || true

echo "Run PHP-FPM in the background as a daemon"
php-fpm


