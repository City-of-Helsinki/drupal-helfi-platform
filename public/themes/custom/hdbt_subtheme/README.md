# HDBT Subtheme

## Introduction

HDBT Subtheme is a so called "starterkit" which you can start using by enabling it in `/admin/appearance`.

Or if you don't accept the theme name, you can rename every `hdbt_subtheme` file with `your_theme_name` and renaming every `hdbt_subtheme_*` variable/reference with `your_theme_name_*`. And then enable it in `/admin/appearance`.

Of course you have a choice to not use it at all by just deleting the whole folder.

HDBT Subtheme uses webpack module bundler to compile the JS and SCSS files. Also the SVG icons are combined in to a sprite.svg via webpack.

As the HDBT Subtheme is only distributed via the [HELfi Platform](https://github.com/City-of-Helsinki/drupal-helfi-platform), it doesn't have an upgrade path per se. In case there is a demand for upgradeability for existing projects then of course we will consider changing the theme to an upgradeable model.

## Requirements

HDBT Subtheme requires HDBT theme as a base theme and it should be installed in `/themes/custom/hdbt`.

Requirements for developing:
- [NodeJS ( ^ 16.10 )](https://nodejs.org/en/)
- [NPM](https://npmjs.com/)
- optional [NVM](https://github.com/nvm-sh/nvm)

## Commands

| Command       | Description                                                                       |
| ------------- | --------------------------------------------------------------------------------- |
| nvm use       | Uses correct Node version chosen for the subtheme compiler                        |
| npm i         | Install dependencies and link local packages.                                     |
| npm ci        | Install a project with a clean slate. Use especially in travis like environments. |
| npm run dev   | Compile styles for development environment and watch file changes.                |
| npm run build | Build packages for production. Minify CSS/JS. Create icon sprite.                 |

Setup the developing environment by running

    nvm use
    npm i

Explanations for commands.
- `nvm use` : Install and use the correct version of Node.
- `npm i` : As stated above; Install dependencies and link local packages.

Start SCSS/JS watcher by running

    npm run dev

Build the minified versions of CSS/JS into dist with

    npm run build

## Structure for files and folders

```
hdbt_subtheme
│   README.md
└───templates
│   └───block
│   └───content
│   └───...
└───src
│   └───scss
│   │   │   styles.scss
│   │   └───base
│   │   │   └───__index.scss
│   │   │   └───_base.scss
│   │   │   └───...
│   │   └───components
│   │   │   └───__index.scss
│   │   │   └───...
│   │   └───...
│   └───js
│   │   │   common.js
│   └───icons
│       |   some-icon.svg
└───dist
    └───css
        |   styles.min.css
    └───js
        |   bundle.min.js
    └───icons
        |   sprite.svg
```

## How tos

### How can I add a new SVG icon and then use it on my site.

You can add your custom icons to `./src/icons/`. F.e. `my-awesome-icon.svg`.
Running `nvm use && npm i && npm run build` will collect the icon to the sprite.svg and it should then be available for use on your site by calling `my-awesome-icon`. Just remember to clear caches.
The icons can be used in twig like so:

    {# HDBT Subtheme specific icons #}
    {% include "@hdbt_subtheme/misc/icon.twig" with {icon: 'my-awesome-icon'} %}

    {# HDBT specific icons #}
    {% include "@hdbt/misc/icon.twig" with {icon: 'google-view'} %}

To use the icon in SCSS, you can call it like so:

    background-image: url('../icons/my-awesome-icon.svg');

### My javascript has unexpected errors when loading a page in Drupal.

If you have compiled the code with dev-flag (`nmp run dev`), then the sourcemaps expects the JS files to be found in correct places.
This means that JS preprocessing (minifying) should be turned off. Just add the following lines to local.settings.php.
```
$config['system.performance']['css']['preprocess'] = 0;
$config['system.performance']['js']['preprocess'] = 0;
```

### I need to rebuild caches every time I build the css or change the twig files. How can I automate it?

You can create a `local.settings.php` and `local.services.yml` files to `/sites/default/` folder and paste the following contents in them.

**_Keep in mind that using the Null Cache Backend is the primary culprit for caching issues. F.e. Something works in local environment, but not in production environment._**

local.services.yml:
```
parameters:
  twig.config:
    debug: true # Displays twig debug messages, developers like them
    auto_reload: true # Reloads the twig files on every request, so no drush cache rebuild is required
    cache: false # No twig internal cache, important: check the example.settings.local.php to fully disable the twig cache

services:
  cache.backend.null: # Defines a Cache Backend Factory which is just empty, it is not used by default
    class: Drupal\Core\Cache\NullBackendFactory
```
local.settings.php:
```
<?php
/**
 * @file
 * An example of Drupal 9 development environment configuration file.
 */
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['page'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';

$settings['skip_permissions_hardening'] = TRUE;

$config['system.performance']['css']['preprocess'] = 0;
$config['system.performance']['js']['preprocess'] = 0;
$config['system.logging']['error_level'] = 'some';
```

### I get some mysterious 404 errors on console after building my theme using the 'npm run dev'
The issue here is actually in the combination of source maps and theme js aggregation. The system cannot find the files
associated with source maps because the aggregation names the files differently. What you need to do is disable js
aggregation from Drupal. Go to /admin/config/development/performance and uncheck 'Aggregate JavaScript files'. Clear
site caches and you should be able to continue with your work.

### How can I add custom translations?
Add your UI translations to ``./translations/{fi/sv}.po`` files like it is explained in Translation in Drupal 8 documentation: https://www.drupal.org/docs/understanding-drupal/translation-in-drupal-8.
These translations consists of:

PHP
```
$this->t('Example', [], ['context' => 'My custom context'])
```
Twig
```
{{ 'Example'|t({}, {'context': 'My custom context'}) }}
```
JS
```
const variable = Drupal.t('Example', {}, {context: 'My custom context'});
```

And the way to add the actual translation in to f.e. `fi.po` is done like so:
```
msgctxt "My custom context"
msgid "Example"
msgstr "Esimerkki"
```

Plural example:

```
msgctxt "My custom context"
msgid "Singular"
msgid_plural "Plural"
msgstr[0] "Yksikkö"
msgstr[1] "Monikko"
```

To see these translation changes in an instance, run in container shell:
```
drush locale:check && drush locale:update
```
And then flush all caches from top left drupal admin menu under "Druplicon".
