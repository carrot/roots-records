records = require '../../../../'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {url: 'http://asdfasdfasdfasdf.com'}})]

  jade:
    pretty: true
