records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books: { file: 'data.json' }
    )
  ]

  jade:
    pretty: true
