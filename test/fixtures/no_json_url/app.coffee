records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {url: 'http://google.com'}})]

  jade:
    pretty: true
