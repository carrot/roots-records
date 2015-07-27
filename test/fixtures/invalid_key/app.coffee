records = require '../../../../'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {foo: 'bar'}})]

  jade:
    pretty: true
