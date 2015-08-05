records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books: { file: 'data.json' }
      doges: { data: [{ name: 'Dogeman' }, { name: 'Wow' }] }
    )
  ]

  jade:
    pretty: true
