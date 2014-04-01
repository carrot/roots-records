records = require '../../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {data: {foo: "bar"}}})]

  jade:
    pretty: true
