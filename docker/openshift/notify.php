<?php

/**
 * @file
 * A php script to send messages to a configured Slack channel.
 *
 * This script is called from 'docker/openshift/entrypoints/20-deploy.sh'.
 *
 * Configuration:
 *
 * In order for this to work, you must define the following environment
 * variables:
 *
 * - SLACK_CHANNEL_ID
 *     You can find this value by right-clicking the channel name and selecting
 *     Copy -> Copy link. The last part of the link should be the channel ID.
 *
 * - SLACK_AUTHORIZATION
 *    The authorization token for your Slack application.
 *
 * Usage:
 *
 * php notify.php "your message"
 *
 * An additional metadata gathered from configured environment variables will
 * be appended to all messages, such as APP_ENV, OPENSHIFT_BUILD_ID etc.
 *
 * You can pass an optional boolean argument to this script to highlight
 * everyone active in that channel. For example
 *
 * php notify.php "your message" true
 *
 * This will, in addition to everything else, notify everyone active in that
 * channel. Like `@here your message`.
 */

declare(strict_types = 1);

use GuzzleHttp\Client;
use GuzzleHttp\ClientInterface;

include_once __DIR__ . '/../../vendor/autoload.php';

/**
 * A client to interact with Slack API.
 */
final class SlackApiClient {

  /**
   * The HTTP client.
   *
   * @var \GuzzleHttp\ClientInterface
   */
  private ClientInterface $client;

  /**
   * Constructs a new instance.
   *
   * @param string $authorization
   *   The bearer authorization token.
   * @param string $channel
   *   The channel id.
   */
  public function __construct(
    private string $authorization,
    private string $channel,
  ) {
    $this->client = new Client(['base_uri' => 'https://slack.com/api/']);
  }

  /**
   * Sends a Slack message.
   *
   * @param string $message
   *   The message to send.
   */
  public function send(string $message) : void {
    $response = $this->client->request('POST', 'chat.postMessage', [
      'json' => [
        'channel' => $this->channel,
        'text' => $message,
      ],
      'headers' => [
        'Authorization' => 'Bearer ' . $this->authorization,
      ],
    ]);
    $content = json_decode($response->getBody()->getContents());

    if (empty($content->ok) || $content->ok !== TRUE) {
      $message = $content->error;

      if (isset($content->response_metadata->messages)) {
        $message = implode(',', $content->response_metadata->messages);
      }

      throw new InvalidArgumentException($message);
    }
  }

}

$config = [
  'SLACK_CHANNEL_ID' => NULL,
  'SLACK_AUTHORIZATION' => NULL,
];

foreach ($config as $key => $item) {
  if (!$value = getenv($key)) {
    throw new \InvalidArgumentException(sprintf('Missing required "%s" environment variable.', $key));
  }
  $config[$key] = getenv($key);
}

if (!isset($argv[1])) {
  throw new \InvalidArgumentException('Usage: php slack.php "your message"');
}

$metadata = [
  'OPENSHIFT_BUILD_ID' => 'Build ID',
  'OPENSHIFT_BUILD_NAME' => 'Build name',
  'OPENSHIFT_BUILD_SOURCE' => 'Project source',
  'APP_ENV' => 'Environment',
];

$extra = [];
foreach ($metadata as $key => $label) {
  if (!$value = getenv($key)) {
    continue;
  }
  $extra[] = sprintf(">*%s*: %s\n", $label, $value);
}

$client = new SlackApiClient($config['SLACK_AUTHORIZATION'], $config['SLACK_CHANNEL_ID']);
$client->send(vsprintf("%s\n%s\n*Project metadata*: \n\n%s", [
  isset($argv[2]) ? '<!here>' : '',
  $argv[1],
  implode("\n", $extra),
]));
