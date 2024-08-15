# Queue

Apache Artemis is used to manage Drupal queues.

## Configuration

@todo: Figure out what configuration is required.

## Running queues

TBD

## Local development

Make sure your `docker-compose.yml` files is up-to-date.

Modify your project's `.env` file, add `COMPOSE_PROFILES=queue` and (re)start your project: `make stop && make up`.

Add something like this to your `local.settings.php` file:
```php
$settings['stomp']['all'] = [
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
$settings['queue_default'] = 'queue.stomp.all';
```

### List queues

- List available queues: `drush queue:list`
