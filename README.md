# Roots Records

[![NPM version](https://badge.fury.io/js/roots-records.svg)](http://badge.fury.io/js/roots-records) [![tests](http://img.shields.io/travis/carrot/roots-records/master.svg?style=flat)](https://travis-ci.org/carrot/roots-records)
[![coverage](http://img.shields.io/coveralls/carrot/roots-records.svg?style=flat)](https://coveralls.io/r/carrot/roots-records) [![dependencies](http://img.shields.io/gemnasium/carrot/roots-records.svg?style=flat)](https://gemnasium.com/carrot/roots-records)

Load remote data into a [roots](http://www.github.com/jenius/roots) project and make it available in your views as locals.

### Installation

- Make sure you are in your roots project directory
- Run `npm install roots-records --save`
- Modify your `app.coffee` as such:
  ```coffee
  records = require('roots-records')

  # ...

  module.exports =
    extensions: [
      records
        books: { url: 'http://www.google.com/books' },
        shoes: { file: 'data/books.json' },
        scores: { data: { home: 1, away: 0 } }
    ]

  # ...
  ```

### Usage

Roots Records is a extension that you can use to fetch data from a url, file, or JSON object, manipulate it, and inject into your view templates. It can also be used to compile out additional templates for each item in a collection (like single blog posts for a blog), as discussed below in the "options" section.

This extension is a great way to separate markup and content. With Roots Records, you can keep your content in an API, but still compile it out as static content through Roots. In addition, if there's a section of the site you need to be more dynamic, you can still access the exact same data through an ajax request.

### Configuration

You should pass a single options object to the roots-records function. This object can have as many keys as you'd like, each key specifying the name of a set of data you'd like to pull into your views, and with the value of each key an object allowing you to configure from where you'd like to fetch this data and modify it before being injected into your views.

The following options are available:

##### `url, file, or data`

A resource returning JSON that you would like the data from to be included in your views. URLs should be absolute paths including `http`, files should be a path relative to the root of your project, and data is simply a direct JSON object. For example:

```coffee
# using a URL
records
  books: { url: 'http://www.google.com/books' }

# using a file path
records
  books: { file: 'data/books.json' }

# using JSON data
records
  books: { data: [{ title: 'Wow', author: 'Doge' }] }
```

For the `url` option, if you need a bit more control, you can also pass an object instead of a string. The object can have the following values, all optional except for `path`:

```coffee
records
  books:
    url:
      path: 'http://www.google.com/books'
      method: 'GET'
      params: { year: '1980' }
      headers: { Security: 'secret' }
      entity: { authorName: 'Darwin' }
```

For more details on what each option here means and a couple more obscure options, feel free to check the [rest documentation](https://github.com/cujojs/rest/blob/master/docs/interfaces.md#common-request-properties), which is the library internally handling this request.

Note that it is possible to pass multiple different keys to roots-records that fetch data in the same or different ways. For example:

```coffee
records
  books: { url: 'http://www.google.com/books' }
  sodas: { data: ['Dr. Pepper', 'Coke', 'Sprite'] }
```

##### `hook`

An optional function that receives the JSON response and allows you to make modifications to it before it is injected into your views. For example:

```coffee
records
  data: { foo: 'bar' }
  hook: (data) ->
    data.foo = 'changed!'
```

With this modification, the value of `foo` in you views would now be `changed!` rather than `bar`, as it was in the original data passed. This is of course a contrived example, for more complex data, more interesting transformations can be done here.

##### `template` and `out`

So imagine this. You are making a blog, and roots-records is pulling from your blog's API and returning an array of blog posts. In addition to using the locals to list out an index of your posts, you also want to compile a standalone single page view for the each full blog post. Roots records can still handle this with a set of three options, You can use the `template` option to specify a single view template which will be used to render out each single item in your collection. The `out` option is a function that receives each individual option in your collection as an argument. You should return the path, relative to the project root, to which you'd like to write your single view. For example:

```coffee
records
  books:
    url: 'http://www.google.com/books',
    hook: (res) -> res.response.books,
    template: "views/_book.jade",
    out: (book) -> "/books/#{slugify(book.title)}"
```

Note that the `slugify` function in the last piece is fictional, although you can find similar string transformation functionality in the [underscore.string library](https://github.com/epeli/underscore.string) if you need it. Also note that in order for this single page views to work correctly, the data you are returning *must be an array* -- you can also use the `hook` option to make this transformation if necessary, as shown in the example above.

Inside your single view templates, the data for your item can be accessed with the `item` key. In addition, the full contents of the `records` locals will still be available inside all single view templates.

### Accessing Data In Your Templates

In your view templates, all roots-records data will be available under the `records` local. So, for example, if you have a `books` key that's pulling some book data as shown in many examples above, in your views you would be able to access this data under `records.books`, as such:

```jade
!= JSON.stringify(records.books)
```

In a jade template, this example would simply print out the contents of the `books` data that you pulled. Of course you can chop up and iterate this data further in any way you need using jade, or whatever other templating engine you are using. And of course if you are fetching multiple data sources, each one will be found on `records` under what you named it when passing options to roots-records.

If you are using single view templates through the `template` and `out` options, you can access all data as usual through `records`, and additionally will find an `item` local, through which you can access the data for the specific item in the collection that the view is for.

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
