records = require '../../..'

module.exports =
  ignores: ["**/_*"]

  extensions: [
    records(
      books:
        data: { title: "The Great Dogesby" }
        template: '_single.jade'
        out: (obj) -> "posts/#{obj.title}.html"
    )
  ]

  jade:
    pretty: true
