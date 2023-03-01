# Automatic updates

The automatic update bot can be used to:

- Automatically update config changes, like feature changes from `helfi_drupal_platform` module
- Update changed `drupal-helfi-platform` files using ([helfi_drupal_tools](https://github.com/City-of-Helsinki/drupal-tools)).
- Update `drupal/helfi_*` and `drupal/hdbt*` packages using Composer.

## The problem this is trying to solve

We’ve been testing different services for updating Drupal packages/dependencies automatically, such as Renovate and Dependabot. Even though they work great on paper, we always ended up having the same issue: database updates.

For example:

- Commerce module receives an update that:
  - [Adds a new field](https://git.drupalcode.org/project/commerce/-/blob/8.x-2.x/modules/order/commerce_order.install#L231) and a [dependency to Token module](https://git.drupalcode.org/project/commerce/-/blob/8.x-2.x/commerce.install#L30).
- Dependabot/Renovate updates Commerce to the latest version.
- The next deployment installs the updated Commerce, runs config import, database updates and installs the missing field and token dependency.
- At this point, your active configuration (in database) has the required changes, but the configuration stored in Git does not.
- The next deployment will run the configuration import again and override all changes done by previous deployment, meaning the code depending on that new field or Token module will suddenly break.

This made the whole automatic update process pretty useless since we always had to manually run database updates and commit the changed configuration to Git anyway.

## How we solved it

We use GitHub Actions to automate database update/config export process. See [.github/workflows/update-config.yml](/.github/workflows/update-config.yml.dist).

In the simplest terms it just:

1. Install Drupal: `drush site-install --existing-config`
2. Flush caches and re-import configuration to make sure everything is up-to-date: `drush cr`, `drush config:import`.
3. Update required dependencies using `composer`.
4. Run update hooks and export configuration: `drush updb`, `drush config:export`.
5. Commit changed files to repository. We use [peter-evans/create-pull-request@v4](https://github.com/peter-evans/create-pull-request) Action to create a pull request, so we can run tests/code checks against the changes.

You can see this in action [here](https://github.com/City-of-Helsinki/drupal-helfi-kymp/pull/302/files).

Installing Drupal from scratch (with existing configuration) can take a really long time, especially for more complex sites.

We speed things up by creating a “reference” database dump and install Drupal using that dump. The database dump is created by [.github/actions/artifact.yml.dist](/.github/workflows/artifact.yml) Action and stored as workflow artifact using [actions/upload-artifact](https://github.com/actions/upload-artifact).

The database dump is also used by all our automated tests.

## Adding update bot to your project

### Artifact action

Enable the `artifact` action by adding [.github/workflows/artifact.yml](/.github/workflows/artifact.yml.dist) file to your repository. *NOTE*: `.github/workflows/artifact.yml.dist` might already exist, if it does then you can just rename it to `artifact.yml`.

The workflow is only run in repository's default branch. It's recommended to have your development branch as your default branch to speed up the update process.

Once you have the action set up, go to Actions -> Build artifact -> Run workflow:

![Update config workflow](/documentation/images/workflow.png)

This will generate an SQL-dump based on your site's current configuration and save it as an artifact and will be used by `Update config` action to speed up the installation process.

The action will be run automatically once a week after you first run it.

### Update config action

Enable the `update-config` action by adding [.github/workflows/update-config.yml](/.github/workflows/update-config.yml.dist) file to your repository. *NOTE*: `.github/workflows/update-config.yml.dist` might already exist, if it does then you can just rename it to `update-config.yml`.

Then run the Update config action by going to Actions -> Update config -> Run workflow.

## Triggering updates automatically

The `Update config` action is never run by default. You can either receive updates automatically on platform updates or set it to update on schedule.

### On platform updates

If you wish to receive automatic updates every time we publish a release to any of our packages, your project must be whitelisted by us.

To get your project whitelisted you can either contact us directly or:

- Fork [City-of-Helsinki/drupal-repository](https://github.com/City-of-Helsinki/drupal-repository) and add your project's repository to: https://github.com/City-of-Helsinki/drupal-repository/blob/3.x/console.php#L13
- Create a pull request

### Scheduled updates

The `Update config` action is never updated automatically, so you can modify it any way you want. For example, you can set it to run on schedule using the `schedule` event.

See [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule) for different ways to trigger it automatically.

## Developing

### Automatically trigger config update on all whitelisted projects

If you want your custom module's releases to trigger update bot on all whitelisted projects, you can use [drupal-repository](https://github.com/City-of-Helsinki/drupal-repository) webhook server to trigger the `config_change` dispatch event.

Go to your repository's Settings -> Webhooks -> Add webhook

Settings:
- Payload URL: Contact helfi dev team
- Secret: Contact helfi dev team
- Select individual events that trigger the webhook: `releases`

We use Github account called `hel-platta-automation` to trigger the dispatch event via Github API. Go to your repository's `Settings` -> `Collaborators and teams`, click `Add people` and give `hel-platta-automation` user `write` permissions to your repository.

See https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event.

