<?php

declare(strict_types=1);

namespace Drupal\Tests\dtt\ExistingSite;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Group;
use weitzman\DrupalTestTraits\ExistingSiteBase;

/**
 * Tests that disallowed modules and configuration are not enabled.
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
    return [
      'mock responses' => ['helfi_api_base.features', 'use_mock_responses', TRUE],
    ];
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
  public function testConfigValueNotSet(string $name, string $key, mixed $value): void {
    $this->assertNotEquals(
      $value,
      $this->container->get('config.factory')->get($name)->getOriginal($key, FALSE),
      sprintf('Configuration "%s:%s" must not be set to %s.', $name, $key, var_export($value, TRUE)),
    );
  }

}
