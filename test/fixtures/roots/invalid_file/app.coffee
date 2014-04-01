records = require '../../../../'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {file: '/asdf/asdf/asdf'}})]

  jade:
    pretty: true
