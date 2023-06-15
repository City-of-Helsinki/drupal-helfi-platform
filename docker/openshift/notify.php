<?php

/**
 * @file
 * A php script to send alerts from CLI tasks to Sentry.
 *
 * This script is called from 'docker/openshift/entrypoints/20-deploy.sh'.
 *
 * Configuration:
 *
 * In order for this to work, you must define the following environment
 * variables:
 *
 * - SENTRY_DSN
 *    The DSN address to Sentry, something like 'https://xxxx@xxx.hel.fi/xxx'.
 * - SENTRY_ENVIRONMENT
 *    The environment name.
 *
 * Usage:
 *
 * php notify.php "your message"
 *
 * An additional metadata gathered from configured environment variables will
 * be appended to all messages, such as APP_ENV, OPENSHIFT_BUILD_ID etc.
 */

declare(strict_types = 1);

use Sentry\ClientInterface;
use Sentry\State\Scope;
use function Sentry\configureScope;
use function Sentry\init;

include_once __DIR__ . '/../../vendor/autoload.php';

if (!interface_exists(ClientInterface::class)) {
  throw new LogicException('Missing "sentry/sdk" dependency.');
}

class DeploymentException extends \Exception {
}

$config = [
  'SENTRY_DSN' => NULL,
  'SENTRY_ENVIRONMENT' => NULL,
];

foreach ($config as $key => $item) {
  if (!$value = getenv($key)) {
    throw new InvalidArgumentException(sprintf('Missing required "%s" environment variable.', $key));
  }
  $config[$key] = getenv($key);
}

init();

if (!isset($argv[1])) {
  throw new InvalidArgumentException('Usage: php notify.php "your message"');
}

$metadata = [
  'APP_ENV' => 'Environment',
  'OPENSHIFT_BUILD_NAMESPACE' => 'Namespace',
  'OPENSHIFT_BUILD_NAME' => 'Build name',
  'OPENSHIFT_BUILD_SOURCE' => 'Project',
];

$extra = [];
foreach ($metadata as $key => $label) {
  if (!$value = getenv($key)) {
    continue;
  }
  $extra[$label] = $value;
}

if (!empty($extra)) {
  configureScope(fn (Scope $scope) => $scope->setContext('meta', $extra));
}
throw new \DeploymentException($argv[1]);
