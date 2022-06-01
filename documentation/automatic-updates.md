# Automatic updates

The automatic update bot can be used to:

- Automatically update config changes, like feature changes from `helfi_drupal_platform` module
- Update changed `drupal-helfi-platform` files using ([helfi_drupal_tools](https://github.com/City-of-Helsinki/drupal-tools)).
- Update `drupal/helfi_*` and `drupal/hdbt*` packages using Composer.

### How it works

The idea behind this is to create an SQL-dump once a week from your site's active configuration. The dump is then used as a reference point by `Update config` GitHub action to determine if your site is missing any configuration updates.

Tasks done by Update config action:

1. Install the site using the reference SQL-dump.
2. Import the configuration (`drush config:import`) to make sure everything is up-to-date before updating anything.
3. Update packages listed earlier.
4. Run the database update-hooks (`drush updb`).
5. Export the configuration (`drush config:export`).
6. Create a pull request of any files changed in process.

This is useful beyond just updating the changes from `drupal-helfi-platform` for a few reasons, like to ensure that configuration changes done by update hooks are always exported to repository.

You can see it in action [here](https://github.com/City-of-Helsinki/drupal-helfi-kymp/pull/302/files).

## Adding update bot to your project

### Artifact action

Enable the `artifact` action by adding [.github/workflows/artifact.yml](/.github/workflows/artifact.yml.dist) file to your repository. *NOTE*: `.github/workflows/artifact.yml.dist` might already exist, if it does then you can just rename it to `artifact.yml`.

The workflow is only run in repository's default branch. It's recommended to have your development branch as your default branch to speed up the update process.

Once you have the action set up, go to Actions -> Build artifact -> Run workflow:

![Update config workflow](/documentation/images/workflow.png)

This will generate a SQL-dump based on your site's current configuration and save it as an artifact and will be used by `Update config` action to determine if your site is missing any platform updates.

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

