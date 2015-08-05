records = require '../../..'
S       = require 'underscore.string'

module.exports =
  ignores: ["**/_*"]

  locals:
    foo: "bar"

  extensions: [
    records(
      books:
        out: (book) -> "/books/#{S.slugify(book.title)}"
        template: "views/_book.jade"
        data: [ { title: 'testing' } ]
      movies:
        data: [ { title: 'a great movie' } ]
    )
  ]

  jade:
    pretty: true
