records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books: { data: 'this is a string not an object' }
    )
  ]

  jade:
    pretty: true
