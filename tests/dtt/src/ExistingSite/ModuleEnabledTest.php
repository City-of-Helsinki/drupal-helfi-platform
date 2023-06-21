<?php

declare(strict_types = 1);

namespace Drupal\Tests\dtt\ExistingSite;

use weitzman\DrupalTestTraits\ExistingSiteBase;

/**
 * Tests if a specific module is enabled.
 *
 * @group dtt
 */
class ModuleEnabledTest extends ExistingSiteBase {

  /**
   * Check if dblog is enabled.
   */
  public function testDbLogEnabled(): void {
    // Assert that the dblog module is not enabled.
    $this->assertFalse(\Drupal::moduleHandler()->moduleExists('dblog'));
  }

}
