records = require '../../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {file: 'test/fixtures/json/path.json'}})]

  jade:
    pretty: true
