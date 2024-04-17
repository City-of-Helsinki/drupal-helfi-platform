# Queue

Apache Artemis is used to manage Drupal queues.

## Configuration

Configure each queue in `all.settings.php`:

```php
<?php
$settings['queue_helfi_navigation_menu_queue'] = 'queue.stomp.default';
```

## Running queues

Create a bash script for each queue:
```shell
# docker/openshift/crons/yourqueue.sh
#!/bin/sh

(while true
do
# Replace helfi_api_base_revision with the queue name.
 drush stomp:worker helfi_api_base_revision --items-limit 100
done) &
```

Add `exec /crons/yourqueue.sh &` to `docker/openshift/crons/base.sh`.

## Local development

Make sure your Docker `compose.yaml` file is up-to-date.

Modify your project's `.env` file, add `COMPOSE_PROFILES=queue` and (re)start the project: `make stop && make up`.

Add something like this to your `local.settings.php` file:
```php
$settings['stomp']['default'] = [
  'clientId' => 'artemis',
  'login' => 'artemis',
  'passcode' => 'artemis',
  'brokers' => 'tcp://artemis:61613',
  'timeout' => ['read' => 15000],
  'heartbeat' => [
    'send' => 12000,
    'receive' => 0,
    'observers' => [
      [
        'class' => '\Stomp\Network\Observer\HeartbeatEmitter',
      ],
    ],
  ],
];
```

### Running queues

- List available queues: `drush queue:list`
- Run a queue: `drush stomp:worker {queue}`
