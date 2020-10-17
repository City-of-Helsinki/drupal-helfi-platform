<?php

// Use druidfi/omen to auto-configure Drupal
//
// You can setup project specific configuration in this directory:
//
// ENV.settings.php and ENV.services.yml
// and
// local.settings.php and local.service.yml
//
// These files are loaded automatically if found.
//
extract((new Druidfi\Omen\DrupalEnvDetector(__DIR__))->getConfiguration());

// Hash salt.
$settings['hash_salt'] = 'oNbAEGiCIhNhXU-hNBmZMLSSR11HUqnXVUdG9IwMDFBft67IXRV4xjao1W20AQ_O5pRQ07PNMg';

/**
 * Only in Wodby environment. @see https://wodby.com/docs/stacks/drupal/#overriding-settings-from-wodbysettingsphp
 */

if (isset($_SERVER['WODBY_APP_NAME'])) {
  // The include won't be added automatically if it's already there.
  include '/var/www/conf/wodby.settings.php';

  // Override setting from wodby.settings.php.
  $settings['config_sync_directory'] = '../conf/cmi';
}
