records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books: { url: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'}
      books_with_options: {
        url:
          path: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'
          method: 'GET'
      }
    )
  ]

  jade:
    pretty: true
