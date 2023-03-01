# Drupal modules

## API Base

Base module for `drupal-helfi-platform` ecosystem. Most modules listed below depend on this. See [available features](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base#features) for more documentation about available feature.

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base)
- [Documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-api-base/blob/main/README.md)

## Azure FS

Azure's NFS file system (used to store/serve files from `sites/default/files`) does not support certain file operations (such as chmod), causing any request that performs them to throw a 5xx error. For example:
- Request that aggregates multiple css/js files together
- Attempt to generate a preview image for file upload.

This module decorates core's `file_system` service to skip unsupported file operations when the site is operating on Azure environment.

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-azure-fs)
- [Documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-azure-fs/blob/main/README.md)

## Drupal tools

See [Automatic updates](/documentation/automatic-updates.md) for more information.

- [Code](https://github.com/City-of-Helsinki/drupal-tools)
- [Documentation](https://github.com/City-of-Helsinki/drupal-tools/blob/main/README.md)

## Hauki

Integrates [Hauki](https://hauki-test.oc.hel.ninja/api_docs/) opening hours service with Drupal.

Very rudimentary MVP. Not developed at the moment.

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-hauki)

## Platform config

This module holds configuration for the Hel.fi platform.

- [Code](https://github.com/City-of-Helsinki/drupal-helfi-platform-config)
- [Documentation](https://github.com/City-of-Helsinki/drupal-helfi-platform-config/blob/main/README.md)

## Proxy

Provides various fixes to allow multiple Drupal instances to be served from one domain (www.hel.fi).

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-proxy)
- [Documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-proxy/blob/main/README.md)

## TPR

Provides an integration for [Helsinki Service Map](https://www.hel.fi/palvelukarttaws/restpages/index_en.html) and [Helsinki Service Register](https://www.hel.fi/palvelukarttaws/restpages/palvelurekisteri_en.html) services.

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-tpr)
- [Documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-tpr/blob/main/README.md)

## Tunnistamo

Provides an integration for [Tunnistamo](https://dev.hel.fi/authentication) SSO authentication service.

- [Code](https://github.com/City-of-Helsinki/drupal-module-helfi-tunnistamo)
- [Documentation](https://github.com/City-of-Helsinki/drupal-module-helfi-tunnistamo/blob/main/README.md)
