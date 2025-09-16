<?php

/**
 * @file
 * Contains azure specific settings.php changes.
 */

// Azure specific filesystem fixes.
$settings['php_storage']['twig']['directory'] = '/tmp';
$settings['php_storage']['twig']['secret'] = $settings['hash_salt'];
$settings['file_chmod_directory'] = 16895;
$settings['file_chmod_file'] = 16895;

$config['system.performance']['cache']['page']['max_age'] = 86400;
$config['filelog.settings']['location'] = '/tmp';

// Keep old assets for three months (default is one month).
$config['system.performance']['stale_file_threshold'] = 7776000;

$settings['is_azure'] = TRUE;

/**
 * Deployment identifier.
 *
 * Use OpenShift build name (like 'drupal-1234') to determine
 * if container needs to be invalidated and rebuilt.
 *
 * This should fix the issue where deployment fails due to changed service
 * parameters.
 */
$settings['deployment_identifier'] = getenv('OPENSHIFT_BUILD_NAME');
