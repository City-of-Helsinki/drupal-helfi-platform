// This file gets the yaml formatted stylelint configuration from relative hdbt folder and outputs it as an object.
// This way we have one source of truth for stylelint configuration

const yaml = require('js-yaml');
const fs = require('fs');

// Get document, or throw exception on error
try {
  const doc = yaml.load(fs.readFileSync('../../contrib/hdbt/.stylelintrc.yaml', 'utf8'));
  // console.log(doc);
  module.exports = doc;
} catch (e) {
  console.log(e);
}
