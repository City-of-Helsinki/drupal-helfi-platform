# Local environment

## Docker compose profiles

Compose profiles are used to only run services that are actually needed. For example, there is no reason to start `elasticsearch` or `artemis` containers if your project is not using them.

Modify the value of `COMPOSE_PROFILES` environment variable from `.env` file or start the project with `COMPOSE_RROFILES=your-profiles make up`.

