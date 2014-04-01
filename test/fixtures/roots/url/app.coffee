records = require '../../../../'

module.exports =
  ignores: ["**/_*"]

  extensions: [records({books: {url: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby'}})]

  jade:
    pretty: true
