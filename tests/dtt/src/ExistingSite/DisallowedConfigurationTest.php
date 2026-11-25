<?php

declare(strict_types=1);

namespace Drupal\Tests\dtt\ExistingSite;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Group;
use Symfony\Component\Yaml\Yaml;
use weitzman\DrupalTestTraits\ExistingSiteBase;

/**
 * Tests that disallowed modules and configuration are not enabled.
 *
 * Projects can add their own configuration checks to
 * disallowed_configuration.yml in this directory:
 *
 * @code
 * my_module.settings:
 *   debug: true
 *   api.base_url: 'https://example.com'
 * @endcode
 */
#[Group('dtt')]
class DisallowedConfigurationTest extends ExistingSiteBase {

  /**
   * Modules that must never be enabled in production.
   *
   * @return array<string, array{string}>
   *   The test cases.
   */
  public static function disallowedModules(): array {
    return [
      'dblog' => ['dblog'],
      'helfi_test_content' => ['helfi_test_content'],
    ];
  }

  /**
   * Configuration values that must never be set in production.
   *
   * @return array<string, array{string, string, mixed}>
   *   The test cases: config name, key and the disallowed value.
   */
  public static function disallowedConfig(): array {
    return self::toTestCases([
      'helfi_api_base.features' => [
        'use_mock_responses' => TRUE,
      ],
    ]);
  }

  /**
   * Project-specific configuration values from disallowed_configuration.yml.
   *
   * @return array<string, array{string, string, mixed}>
   *   The test cases: config name, key and the disallowed value.
   */
  public static function projectDisallowedConfig(): array {
    $file = __DIR__ . '/disallowed_configuration.yml';

    if (!file_exists($file)) {
      return [];
    }

    return self::toTestCases(Yaml::parseFile($file) ?? []);
  }

  /**
   * Tests that the given module is not enabled.
   */
  #[DataProvider('disallowedModules')]
  public function testModuleNotEnabled(string $module): void {
    $this->assertFalse(
      $this->container->get('module_handler')->moduleExists($module),
      sprintf('Module "%s" must not be enabled.', $module),
    );
  }

  /**
   * Tests that the given configuration value is not set.
   */
  #[DataProvider('disallowedConfig')]
  #[DataProvider('projectDisallowedConfig')]
  public function testConfigValueNotSet(string $name, string $key, mixed $value): void {
    $this->assertNotEquals(
      $value,
      $this->container->get('config.factory')->get($name)->getOriginal($key, FALSE),
      sprintf('Configuration "%s:%s" must not be set to %s.', $name, $key, var_export($value, TRUE)),
    );
  }

  /**
   * Converts disallowed values keyed by config name and key to test cases.
   *
   * @param array<string, array<string, mixed>> $config
   *   Disallowed values keyed by config name and key.
   *
   * @return array<string, array{string, string, mixed}>
   *   The test cases: config name, key and the disallowed value.
   */
  private static function toTestCases(array $config): array {
    $cases = [];
    foreach ($config as $name => $values) {
      foreach ($values as $key => $value) {
        $cases["$name:$key"] = [$name, (string) $key, $value];
      }
    }
    return $cases;
  }

}
