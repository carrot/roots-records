records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records({
      books: {
        data: {
          foo: "bar"
        },
        hook: (obj) ->
          obj.foo = "doge"
          return obj
      }
    })
  ]

  jade:
    pretty: true
