# Changelog

## 2021-05-12.1

- Excluded all helfi_ prefixed modules from phpunit tests (see phpunit.xml.dist) by default. Use `phpunit.platform.xml` (`vendor/bin/phpunit -c phpunit.platform.xml`) to run ALL tests, including custom helfi modules.
