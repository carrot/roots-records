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

### Options

#### source (either `url`, `file`, or `data`)
The json resource to request.

#### path
A specific key from the requested json to be used.  For example, let's say your json is an object like this:

```coffee
{
 kind: "books",
 items: [
    {
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald"
    }
  ]
}
```

If you want to simply use the value of `"items"`, pass `"items"` to the `path` option, and your record will simply be the `items` array.

### Templates

roots-records stores all results in your locals schema under the `records` key.  So, in your templates, you can access the values of json you named `books` via `records.books`.

## License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
