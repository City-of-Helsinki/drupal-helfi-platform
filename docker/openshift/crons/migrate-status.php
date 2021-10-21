<?php

declare(strict_types = 1);

/**
 * Outputs given variable and value.
 *
 * @param string $key
 *   The variable name to output.
 * @param string $value
 *   The variable value to output.
 * @param mixed $args
 *   Printf variables.
 */
function output_variable(string $key, string $value, ...$args) : void {
  printf("$key='$value'\n", ...$args);
}

/**
 * Generates a UNIX-timestamp for given date.
 *
 * @param string $date
 *   The date.
 *
 * @return int
 *   The unix time or 0.
 */
function unix_time(string $date) : int {
  if ($date === '') {
    return 0;
  }
  try {
    return (int) (new DateTime($date))->format('U');
  }
  catch (\Exception $e) {
  }
  return 0;
}

if (php_sapi_name() !== 'cli') {
  throw new RuntimeException();
}

if (!isset($argv[2], $argv[1])) {
  throw new RuntimeException('Missing argument.');
}

$migrations = explode(',', $argv[1]);
$data = $argv[2];
// Default to 6 hours.
$time = $argv[3] ?? 21600;

if (is_file($data)) {
  $data = file_get_contents($data);
}

if (!($json = json_decode($data)) || !is_array($json)) {
  throw new RuntimeException('Given argument is not a valid json');
}

$reset_status = [];
$skip_migrate = [];

foreach ($json as $migration) {
  if (!in_array($migration->id, $migrations)) {
    continue;
  }
  // Reset migration status.
  if ($migration->status !== 'Idle') {
    $reset_status[] = $migration->id;
  }

  $last_imported = unix_time($migration->last_imported) + $time;

  // Skip migration.
  if ($last_imported && $last_imported > time()) {
    $skip_migrate[] = $migration->id;
  }
}

output_variable('RESET_STATUS', implode(' ', $reset_status));
output_variable('SKIP_MIGRATE', implode(' ', $skip_migrate));
