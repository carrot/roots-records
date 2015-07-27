records = require '../../../..'
S       = require 'string'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records({
      books: {
        out: (book) -> "/books/#{S(book.title).slugify().s}"
        collection: (d) -> "not an array"
        template: "views/_book.jade"
        data: { test: 'test' }
      }
    })
  ]

  jade:
    pretty: true
