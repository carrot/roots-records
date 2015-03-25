roots-records
=============

[![NPM version](https://badge.fury.io/js/roots-records.svg)](http://badge.fury.io/js/roots-records) [![tests](https://travis-ci.org/carrot/roots-records.png?branch=master)](https://travis-ci.org/carrot/roots-records)

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
      records({
        books: {url: 'http://www.google.com/books'},
        shoes: {file: 'data/books.json'},
        scores: {data: {home: 1, away: 0}}
      })
    ]

  # ...
  ```

### Usage

Let's say you've constructed a static site with roots, but want to use a cms to update content. You've got two options:

- you can use [roots-client-templates](https://github.com/carrot/roots-client-templates) to precompile templates and write js which requests the json on page load (or whenever) and outputs the templates, or..
- you can use this extension, which provides a simple method for grabbing json via a url or path and exposes the object to your template engine as locals.

The difference here is that with roots-records, the json is requested when roots compiles and provided to your template engine as locals.  Every time `$ roots compile` is called, the specified json is requested and provided to your locals schema.  Note that this will slow the compilation process, as your json is requested on every compile.

#### Specifying json

The `records` method returned has one argument.  Pass an object like this:

```coffee
module.exports =
  extensions: [
    records({
      books: {url: 'http://www.google.com/books', path: 'items'}
    })
  ]
```

Note that an exception will be thrown on compilation if the resource is unavailable.

#### Single Views

You can compile stand alone single page views from any of your records objects using whatever view template you'd like by passing in `template`, `collection`, and `out`:

```coffee
module.exports =
  extensions: [
    records({
      books: {
        url: 'http://www.google.com/books',
        template: "views/_book.jade",
        collection: (d) -> d.response.books,
        out: (book) -> "/books/#{S(book.title).slugify().s}"
      }
    })
  ]
```

### Options

#### source (either `url`, `file`, or `data`)
The json resource to request.

#### hook
A function that is passed in the JSON data for your record and allows you to manipulate the data before your templates are compiled. Whatever this function returns will be set for your record's key.

For example, with the following hook function:

```coffee
extensions: [
  records({
    books: {
      data: {
        foo: "bar"
      }, 
      hook: (obj) ->
        obj.foo = "doge"
        return obj
    }
  })
]
```

And the following template:

```jade
h1= records.books.foo
```

Should result in an output of the following:

```html
<h1>doge</h1>
```

### Single View Options

These options should be used if you want to generate stand alone single views for a collection of data in your record.

#### template
The path to the template to use for each object in the collection.

#### collection
A function that's passed in the JSON data for that record and returns an array of objects that will be iterated over to build the single page views.

#### out
A function that's passed each iterated object in the collection and returns the path where that view's outputted HTML file will be saved.

### Templates

roots-records stores all results in your locals schema under the `records` key.  So, in your templates, you can access the values of json you named `books` via `records.books`.

## License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
