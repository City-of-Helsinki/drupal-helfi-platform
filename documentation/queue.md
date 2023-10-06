# Queue

Apache Artemis is used to manage Drupal queues.

## Configuration

Add and expose the following environment variables:

```bash
# This should be something like 'tcp://route-to-artemis:61613'.
ARTEMIS_BROKERS
# The username of Artemis service.
ARTEMIS_LOGIN
# The password of Artemis service.
ARTEMIS_PASSCODE
```

@todo: Figure out where to find these values.

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

### Running queues

- List available queues: `drush queue:list`
- Run a queue: `drush queue:run {queue}`
