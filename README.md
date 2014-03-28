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

### Usage

Let's say you've constructed a static site with roots, but want to use a cms to update content. You've got two options:

- you can use [roots-client-templates](https://github.com/carrot/roots-client-templates) to precompile templates and write js which requests the json on page load (or whenever) and outputs the templates, or..
- you can use this extension, which provides a simple method for grabbing json via a url or path and exposes the object to your template engine as locals. 

The difference here is that with roots-records, the json is requested when roots compiles and provided to your template engine as locals.  Every time `$ roots compile` is called, the specified json is requested and provided to your locals schema.  Note that this will slow the compilation process, as your json is requested on every compile. 

#### Specifying json

The `records` method returned on require accepts one argument: an array of hashes which specify the json you'd like to request on compile.

```coffee
  module.exports =
    extensions: [
      records([
        {
          name: 'books',
          from: 'https://www.googleapis.com/books/v1/volumes?q=The+Great+Gatsby',
          path: 'items'
        }
      )
    ]
```

### Options

#### name
The parent key in the records hash to be provided to your locals schema.  For example, `'books'` makes the requested json available to templates as `records.books`.

#### from
The resource.  This can be a URL, file path, or an object.  Note that an exception will be thrown on compilation if the resource is unavailable.

#### path
The route to the key in your json object to act as the "parent."  What does this mean?  Let's say the json requested has an `items` key, and that's all you want.  Specifying `items` as the `path` means that your locals will only receive the value of the `items` key in your json.

### Templates

roots-records stores all results in your locals schema under the `records` key.  So, in your templates, you can access the values of json you named `books` via `records.books`.

## License & Contributing

Coming soon...
