# HDBT subtheme dependencies

The `hdbt_subtheme` in every Drupal instance is built with the theme builder in [drupal-hdbt](https://github.com/City-of-Helsinki/drupal-hdbt/tree/main/theme-builder). The theme builder provides the build tools, the linters and their dependencies, so most updates only need a change in hdbt.

## How the subtheme is kept up to date

### What lives where

| File | Owner | Updated by |
|------|-------|------------|
| `hdbt/theme-builder/package.json` | hdbt | An hdbt release |
| `hdbt_subtheme/.npmrc`, `.nvmrc`, `biome.json` | Platform | `drush helfi:tools:update-platform` copies them from the platform `main` |
| `hdbt_subtheme/package.json` | Instance | drupal-tools update hooks change the managed keys only |
| `hdbt_subtheme/theme-builder.mjs`, `src/` | Instance | The instance developers |
| `hdbt_subtheme/package-lock.json`, `dist/` | Instance | The `Update config` action or the instance developers |

The subtheme `package.json` declares only `@hdbt/theme-builder`, `npm-run-all2` and the overrides. The builder is installed from `../../contrib/hdbt/theme-builder` with `install-links=true`, so npm copies it into `node_modules` and installs its dependencies there. The `preinstall` script reinstalls the builder on every `npm i`, so the copy follows hdbt.

### The `Update config` action

Every dispatch of the [Update config](automatic-updates.md) action runs three jobs.

1. `update-config`
   * Runs `composer update`, which pulls the latest hdbt release.
   * Runs `drush helfi:tools:update-platform`, which copies the platform files and runs the drupal-tools update hooks.
   * Exports the configuration and creates or updates the `update-configuration` pull request.
2. `update-theme-build` runs only when the pull request was created or updated.
   * Checks out hdbt at the commit in `composer.lock`.
   * Runs `npm install ../../contrib/hdbt/theme-builder` to pick up the builder changes.
   * Runs `npm update` for packages with a critical advisory.
   * Runs `npm run build` without network access.
3. `update-theme-commit` commits `package-lock.json` and `dist/` to the pull request.

Everything else stays as locked. Newer versions and non-critical advisories wait until the builder changes.

Review the `dist/` changes in the pull request. A configuration only update should not change them.

### Local development

Run the npm commands in the subtheme folder. The build scripts need Docker.

The subtheme requires npm 12. Node 24 ships npm 11, so run `npm install --global npm@12` once after `nvm use`.

```bash
cd public/themes/custom/hdbt_subtheme
npm i
npm run dev
```

| Command | Does |
|---------|------|
| `npm i` | Installs the dependencies and picks up the builder changes from hdbt |
| `npm run dev` | Builds a development build and rebuilds on changes |
| `npm run build` | Formats, lints and builds a production build |
| `npm run lint` | Lints the SCSS and JavaScript |

The build scripts run in a Node container without network access through the `sandbox` command.

Run `npm run build` and commit `package-lock.json` and `dist/` before pushing.

### Install scripts

| Script | Command | Does |
|--------|---------|------|
| `preinstall` | `rm -rf node_modules/@hdbt/theme-builder && npm install ../../contrib/hdbt/theme-builder` | Replaces the builder copy and updates its dependencies from hdbt |
| `postinstall` | `npm --prefix ../../contrib/hdbt install` | Installs the hdbt dependencies. Only subthemes with React apps keep it |

* `npm i` and `npm ci` run `preinstall` before they install anything. Without it, `npm i` keeps the old builder copy in `node_modules` after an hdbt update.
* The `preinstall` removes the copy first. npm keeps a copy with the same version even when its files changed.
* The `preinstall` does not loop. npm runs the install scripts only for an `npm install` without arguments.
* React apps import `react`, `hds-react` and `lodash-es` from the hdbt `node_modules`, so subthemes with a `tsconfig.json` keep the `postinstall`.
* The `Update config` action installs with `--ignore-scripts` and installs the builder by path itself.
* hdbt, hdbt_admin, `helfi_platform_config` and `helfi_calculator` have the same `preinstall` with their own path to the builder.

## Update a package in all instances

### Builder packages

Packages such as `sass`, `esbuild`, `postcss`, `stylelint`, `@biomejs/biome` and `hds-design-tokens` come from the builder.

1. Raise the version in `hdbt/theme-builder/package.json`. See [Minor and major versions](#minor-and-major-versions).
2. Run `npm install` and `npm test` in `theme-builder/`.
3. Build hdbt, hdbt_admin and a subtheme to check the output.
4. Release hdbt.

The next `Update config` run updates `package-lock.json` and `dist/` in every instance.

### Subtheme packages

Packages declared in the subtheme `package.json`, such as `npm-run-all2`.

1. Change the version in `public/themes/custom/hdbt_subtheme/package.json` in the platform.
2. Add an update hook to [drupal-tools](https://github.com/City-of-Helsinki/drupal-tools) `src/Update/migrations.php` that sets the same version.
3. Release drupal-tools.

```php
/**
 * UHF-XXXXX: Update npm-run-all2 in hdbt_subtheme.
 */
function drupal_tools_update_30() : UpdateResult {
  $file = 'public/themes/custom/hdbt_subtheme/package.json';

  if (!file_exists($file)) {
    return new UpdateResult(['Skipped, hdbt_subtheme has no package.json.']);
  }
  $package = json_decode((string) file_get_contents($file));
  $package->dependencies->{'npm-run-all2'} = '^9.0.0';

  $json = json_encode($package, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
  // Indent with two spaces like npm.
  $json = preg_replace_callback('/^(?: {4})+/m', fn (array $matches) => str_repeat('  ', strlen($matches[0]) / 4), $json);
  file_put_contents($file, $json . "\n");

  return new UpdateResult(['Updated npm-run-all2 in hdbt_subtheme.']);
}
```

Prefer moving shared packages into the builder. A builder change needs only an hdbt release.

## Minor and major versions

### Minor and patch

Raise the minimum of the range, for example `"sass": "^1.89.2"` to `"sass": "^1.93.0"`.

The installs keep the locked version while it satisfies the range. Raising only the maximum or leaving the range as is changes nothing.

### Major

Change the major in the range, for example `"stylelint": "^16.0.0"` to `"stylelint": "^17.0.0"`.

* Read the changelog for breaking changes.
* Update `.stylelintrc.yaml`, `biome.json` or the builder code when the package needs it.
* Build hdbt, hdbt_admin, `helfi_platform_config` and a subtheme, and compare `dist/`.

### Test a builder change in an instance

1. Push the hdbt branch.
2. Run `composer require drupal/hdbt:dev-<branch>` in the instance.
3. Run `npm i` and `npm run build` in the subtheme.
4. Revert `composer.json` and `composer.lock` after testing.

## Override a package

Use an override to force a version of a package that the builder pulls in, for example to fix a vulnerability before the upstream package does.

Only the overrides in the subtheme `package.json` apply. The overrides in the builder `package.json` apply to the builder tests only.

### One instance

1. Add the override to the subtheme `package.json`.

   ```json
   "overrides": {
     "braces": "^3.0.3"
   }
   ```

2. Run `npm i` and `npm run build` in the subtheme.
3. Commit `package.json`, `package-lock.json` and `dist/`.

### All instances

1. Add the override to the platform subtheme `package.json`.
2. Add a drupal-tools update hook that sets it.

   ```php
   $package->overrides ??= new \stdClass();
   $package->overrides->braces = '^3.0.3';
   ```

3. Release drupal-tools.

Override a nested package with the parent as the key, for example `"svg-sprite": { "glob": "^13.0.0" }`.

Remove the override with another update hook once the builder range includes the fix.

## Update one instance only

Run the commands in the subtheme folder.

```bash
cd public/themes/custom/hdbt_subtheme
npm update <package>
npm install <package>@<version>
```

* `npm update <package>` updates the package within its range anywhere in the tree.
* `npm install <package>@<version>` changes a package declared in the subtheme `package.json`.

Build with `npm run build` and commit `package-lock.json`, `dist/` and the changed `package.json`.

## Vulnerabilities

* Critical advisories with a fix within the range are updated by the next `Update config` run. Run the action manually for an urgent fix.
* Fixes outside the range need a builder update or an override.
* Lower severities are not updated automatically. Fix them with a builder update when needed.
* `min-release-age` in `.npmrc` skips versions published in the last day.
