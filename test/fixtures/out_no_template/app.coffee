records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books:
        data: { title: "The Great Dogesby" }
        out: (obj) -> "posts/#{obj.title}.html"
    )
  ]

  jade:
    pretty: true
