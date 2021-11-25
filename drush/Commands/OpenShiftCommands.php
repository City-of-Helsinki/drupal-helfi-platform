<?php

declare(strict_types = 1);

namespace Drush\Commands;

use Symfony\Component\Process\Process;

/**
 * A Drush commandfile.
 */
final class OpenShiftCommands extends DrushCommands {

  /**
   * Make sure env variables are exposed.
   *
   * @return $this
   *   The self.
   */
  private function ensureEnvVariables() : self {
    static $envVariablesSet;

    if ($envVariablesSet) {
      return $this;
    }
    $envVariablesSet = TRUE;
    $envFile = DRUPAL_ROOT . '/../.env';

    if (file_exists($envFile)) {
      $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
      foreach ($lines as $line) {
        if (str_starts_with(trim($line), '#')) {
          continue;
        }

        [$name, $value] = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);

        if (!array_key_exists($name, $_ENV)) {
          putenv(sprintf('%s=%s', $name, $value));
          $_ENV[$name] = $value;
        }
      }
    }
    return $this;
  }

  /**
   * Ensure that we're logged in.
   */
  private function ensureLoginDetails(string $token = NULL) : self {
    static $attemptedLogin;

    if ($attemptedLogin) {
      return $this;
    }
    $attemptedLogin = TRUE;

    try {
      $this->invokeOc(['whoami'], showOutput: FALSE);
    }
    catch (\Exception $e) {
      $this->invokeOc([
        'login',
        '--token=' . $token,
        '--server=https://api.arodevtest.hel.fi:6443',
        '--insecure-skip-tls-verify',
      ]);
    }

    return $this;
  }

  /**
   * Make sure we have project selected.
   *
   * @return $this
   *   The self.
   */
  private function ensureProject() : self {
    static $projectChanged;

    if (!$project = getenv('OC_PROJECT_NAME')) {
      throw new \Exception(dt('OC_PROJECT_NAME env variable is not set.'));
    }

    if ($projectChanged) {
      return $this;
    }
    $projectChanged = TRUE;

    $this->invokeOc(['project', $project]);
    return $this;
  }

  /**
   * Runs oc command with given arguments.
   *
   * @param array $command
   *   The commands to run.
   * @param callable|null $callback
   *   The callback.
   *
   * @return int
   *   The exit code.
   */
  private function invokeOc(
    array $command,
    ?callable $callback = NULL,
    bool $showOutput = TRUE
  ) : int {
    $this
      ->ensureEnvVariables()
      ->ensureLoginDetails()
      ->ensureProject();

    $fullCommand = 'oc ' . implode(' ', $command);
    $this->io()->note('Running: ' . $fullCommand);
    $process = new Process(['oc', ...$command]);
    $process->start();

    if (!$callback && $showOutput) {
      $process->wait(function ($type, $buffer) {
        $this->io()->write($buffer);
      });
    }

    if ($callback) {
      $process->wait();
      $callback($process->getOutput());
    }

    if ($process->getExitCode() > self::EXIT_SUCCESS) {
      throw new \Exception(dt('Command ' . $fullCommand . ' failed. See above for details.'));
    }
    return self::EXIT_SUCCESS;
  }

  /**
   * Finds the drupal pod name.
   *
   * @param array $items
   *   The items to scan from.
   *
   * @return string
   *   The pod name.
   */
  private function getDrupalPodName(array $items) : string {
    foreach ($items as $item) {
      $labels = $item->metadata->labels ?? NULL;

      if ((!isset($labels->deploymentconfig)) || $labels->deploymentconfig !== 'drupal') {
        continue;
      }
      if ((!isset($item->status->phase)) || $item->status->phase !== 'Running') {
        continue;
      }
      return $item->metadata->name;
    }
    throw new \InvalidArgumentException(dt('No running pod found.'));
  }

  /**
   * Gets the database dump.
   *
   * @command helfi:oc:get-dump
   *
   * @return int
   *   The exit code.
   */
  public function getDatabaseDump() : int {
    $this->invokeOc(['get', 'pods', '-o', 'json'], callback: function ($output) {
      $data = json_decode($output);
      $pod = $this->getDrupalPodName($data->items);

      $this->invokeOc([
        'rsh',
        $pod,
        'drush',
        'sql:dump',
        '--result-file=/tmp/dump.sql',
      ]);
      $this->invokeOc([
        'rsync',
        sprintf('%s:/tmp/dump.sql', $pod),
        DRUPAL_ROOT . '/..',
      ]);
    });
    return self::EXIT_SUCCESS;
  }

  /**
   * The OC login command.
   *
   * @param string $token
   *   The token.
   *
   * @command helfi:oc:login
   *
   * @return int
   *   The exit code.
   */
  public function login(string $token) : int {
    $this->ensureLoginDetails($token);

    return self::EXIT_SUCCESS;
  }

  /**
   * Checks whether user is logged in or not.
   *
   * @command helfi:oc:whoami
   *
   * @return int
   *   The exit code.
   */
  public function whoami() : int {
    try {
      $this->invokeOc(['whoami']);
    }
    catch (\Exception $e) {
      return self::EXIT_FAILURE;
    }
    return self::EXIT_SUCCESS;
  }

}
