records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      {
        books: { url: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'}
        books_with_options_1: {
          url:
            path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
            method: 'GET'
        }
        books_with_options_2: {
          url:
            path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
            method: 'GET'
        }
        books_with_options_3: {
          url:
            path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
            method: 'GET'
        }
        books_with_options_4: {
          url:
            path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
            method: 'GET'
        }
        books_with_options_5: {
          url:
            path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
            method: 'GET'
        }
      },
      2
    )
  ]

  jade:
    pretty: true
