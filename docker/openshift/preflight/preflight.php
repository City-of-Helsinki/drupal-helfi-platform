#!/usr/bin/env php
<?php

/**
 * @file
 * Deployment preflight checks.
 *
 * @see https://github.com/City-of-Helsinki/drupal-helfi-platform/blob/main/documentation/openshift.md for documentation.
 */

declare(strict_types = 1);

/**
 * Collect preflight messages.
 *
 * @param string $message
 *   The message.
 *
 * @return array
 *   The preflight error messages.
 */
function preflight_messages(string $message = '') : array {
  static $messages = [];

  if ($message) {
    $messages[] = $message;
  }
  return $messages;
}

/**
 * Mark preflight check as failed.
 *
 * @param string $message
 *   The message.
 * @param string[]|int[] $variables
 *   The variable substitutions.
 */
function preflight_failed(string $message, string|int ...$variables) : void {
  $message = sprintf('Preflight check failed: %s', sprintf($message, ...$variables));
  preflight_messages($message);
}

/**
 * Checks if given environment variable are set.
 *
 * @param array $items
 *   The environment variables to check.
 *
 * @return bool
 *   TRUE if environment variable is set.
 */
function environment_variable_isset(array $items) : bool {
  foreach ($items as $item) {
    if (getenv($item)) {
      return TRUE;
    }
  }
  return FALSE;
}

$class_loader = require_once './../vendor/autoload.php';
require_once './sites/default/settings.php'; // NOSONAR

$candidates = [
  (getenv('APP_ENV') ?: 'local') . '.preflight.php',
  'all.preflight.php',
];

// Allow additional custom checks to be added.
// Create a 'all.preflight.php' file for checks that need to be run
// on all environments and '{env}.preflight.php' for environment-specific
// checks, for example 'testing.preflight.php'.
foreach ($candidates as $candidate) {
  $fileName = sprintf('%s/%s', __DIR__, $candidate);

  if (!file_exists($fileName)) {
    continue;
  }
  require_once $fileName; // NOSONAR
}

if (isset($preflight_checks['environmentVariables'])) {
  foreach ($preflight_checks['environmentVariables'] as $item) {
    // Allow conditional environment variables. For example,
    // ENV_VAR1|ENV_VAR2 will be treated as (ENV_VAR1 or ENV_VAR2) and
    // will only fail if neither one is defined.
    $parts = explode('|', $item);

    if (!environment_variable_isset($parts)) {
      preflight_failed('Environment variable %s is not set.', implode(', ', $parts));
    }
  }

}
// Fail deployment if any preflight check has failed.
if ($messages = preflight_messages()) {
  echo implode(PHP_EOL, $messages);
  exit(1); // NOSONAR
}
