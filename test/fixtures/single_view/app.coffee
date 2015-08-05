records = require '../../..'
S       = require 'underscore.string'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records({
      books: {
        out: (book) -> "/books/#{S.slugify(book.title)}"
        hook: (d) -> d.response
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
      },
      tvshows: {
        out: (tvshow) -> "/tvshows/#{S.slugify(tvshow.title)}"
        hook: (d) -> d.response
        template: (tvshow) ->
          if tvshow.template then "views/_tvshow_#{tvshow.template}.jade" else "views/_tvshow.jade"
        data: {
          response: [
            {
              title: 'The Lost Room'
              year: '2006'
            },
            {
              title: 'Fringe'
              year: '2008',
              template: 'dynamic'
            }
          ]
        }
      }
    })
  ]

  jade:
    pretty: true
