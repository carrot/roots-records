roots-records
=============

Import objects into [roots](http://www.github.com/jenius/roots)' local schema for use with any template engine.

### Installation
- make sure you are in your roots project directory
- `npm install roots-records --save`
- modify your `app.coffee` as such:
  ```coffee
  records = require('roots-records')
  
  # ...

  module.exports =
    extensions: [
      records([
        {
          name: 'books',
          from: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby',
          path: 'items'
        },
        {
          name: 'tweets',
          from: 'https://userstream.twitter.com/1.1/user.json'
        }
      ])
    ]
    
  # ...
  ```
