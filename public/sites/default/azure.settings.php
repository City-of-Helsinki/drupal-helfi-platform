<?php

/**
 * @file
 * Contains azure specific settings.php changes.
 */

$databases['default']['default']['pdo'] = [
  \PDO::MYSQL_ATTR_SSL_CA => getenv('AZURE_SQL_SSL_CA_PATH'),
  \PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => FALSE,
];
// Azure specific filesystem fixes.
$settings['php_storage']['twig']['directory'] = '/tmp';
$settings['php_storage']['twig']['secret'] = $settings['hash_salt'];
$settings['file_chmod_directory'] = 16895;
$settings['file_chmod_file'] = 16895;

$config['system.performance']['cache']['page']['max_age'] = 86400;
$config['filelog.settings']['location'] = '/tmp';
