records = require '../../../..'
S = require 'string'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records({
      books: {
        out: (book) -> "/books/#{S.slugify(book.title).s}"
        collection: (d) -> d.response
        template: "views/_book.jade"
        data: {
          response: [
            {
              title: 'To Kill a Mockingbird'
              author: 'Harper Lee'
            },
            {
              title: 'Inherent Vice'
              author: 'Thomas Pynchon'
            },
            {
              title: 'The Windup Bird Chronicle'
              author: 'Haruki Murakami'
            }
          ]
        }
      }
    })
  ]

  jade:
    pretty: true
