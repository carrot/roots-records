records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      namespace: 'contentful',
      book_1: {
        file: 'data.json'
      },
      book_2: {
        namespace: 'custom'
        file: 'data2.json'
      }
    )
  ]

  jade:
    pretty: true
