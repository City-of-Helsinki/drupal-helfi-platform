const processArgs = process.argv.slice(2);
const backstopjs = require('backstopjs');

require('dotenv').config({ path: '.env' }); // Get environment from instance .env file

if (!process.env.DRUPAL_HOSTNAME || !process.env.COMPOSE_PROJECT_NAME) {
  process.exitCode = 1;
  console.error(`📕 Environment not found, are you sure the instance .env file can be found in ${envPath}?`);
}

// Upload test reports to public/sites/backstop by default.
const reportBasePath = 'public/sites/backstop';
const hostname = `${process.env.COMPOSE_PROJECT_NAME}:8080`;
const drupalHostname = process.env.DRUPAL_HOSTNAME;
const reportUrl = `https://${drupalHostname}/sites/backstop/html_report/index.html`;

const { scenarios, viewports } = require('./config')(hostname);

const config = {
  // Add filter for label string here if you want to debug a single component, like
  // the events component.
  filter: processArgs[2] ?? null,
  docker: true,
  config: {
    'dockerCommandTemplate': 'docker run --rm --network=stonehenge-network -i --user $(id -u):$(id -g) --mount type=bind,source="{cwd}",target=/src backstopjs/backstopjs:{version} {backstopCommand} {args}',
    'viewports': viewports,
    'scenarios': scenarios,
    'mergeImgHack': true,
    'onBeforeScript': 'onBefore.js',
    'paths': {
      'bitmaps_reference': `${reportBasePath}/bitmaps_reference`,
      'bitmaps_test': `${reportBasePath}/bitmaps_test`,
      'engine_scripts': `backstop/`,
      'html_report': `${reportBasePath}/html_report`,
      'ci_report': `${reportBasePath}/ci_report`
    },
    'report': ['browser'],
    'engine': 'playwright',
    'engineOptions': {
      'browser': 'chromium',
    },
    'asyncCaptureLimit': 10,
    'asyncCompareLimit': 100,
    'debug': false,
    'debugWindow': false,
    'hostname': `${hostname}`,
  }
};

const commandMap = {
  reference: 'reference',
  test: 'test',
  approve: 'approve',
};

let command;
if (processArgs.includes(commandMap.reference)) {
  command = commandMap.reference;
} else if (processArgs.includes(commandMap.test)) {
  command = commandMap.test;
} else if (processArgs.includes(commandMap.approve)) {
  command = commandMap.approve;
} else {
  throw new Error('Missing a known command');
}

backstopjs(command, config)
  .then(() => {
    console.log(`The ${command} command was successful! Check the report here: ${reportUrl}`);
  }).catch((e) => {
  process.exitCode = 255;
  console.error('\n\n📕 ', e, `\n\nCheck the report:\n🖼️  ${reportUrl}`);
});
