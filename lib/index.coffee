fs        = require 'fs'
request   = require 'request'
path      = require 'path'
W         = require 'when'
_         = require 'lodash'
RootsUtil = require 'roots-util'

module.exports = (opts) ->

  class Records

    ###*
     * Creates a locals object if one isn't set.
     * @constructor
     ###

    constructor: (@roots) ->
      @util = new RootsUtil(@roots)
      @roots.config.locals ||= {}
      @roots.config.locals.records ||= []

    ###*
     * Setup extension method loops through objects and
     * returns a promise to get all data and store.
     ###

    setup: ->
      records_fetch_tasks = (exec.call(@, key, obj) for key, obj of opts)
      W.all(records_fetch_tasks)

    ###*
     * Promises to retrieve data, then
     * stores object in locals hash
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
    ###

    exec = (key, obj) ->
      get(obj).tap (res) =>
        respond.call(@, key, obj, res)
      .then (res) =>
        if obj.template
          compile_single_views.call(@,
            (if obj.collection? then obj.collection(res) else res),
            obj.template,
            obj.out
          )

    ###*
     * Determines and calls the appropriate function
     * for retrieving json based on keys in object.
     * @param {Object} obj - the key's parameters
    ###

    get = (obj) ->
      d = W.defer()

      if obj.url?
        url(obj, d.resolver)
      else if obj.file?
        file(obj, d.resolver)
      else if obj.data?
        data(obj, d.resolver)
      else
        throw new Error "A valid key is required"

      return d.promise

    ###*
     * Runs http request for json if URL is passed,
     * adds result to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    url = (obj, resolver) ->
      request obj.url, (error, response, body) ->
        __parse(body, resolver)

    ###*
     * Reads a file if a path is passed, adds result
     * to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    file = (obj, resolver) ->
      fs.readFile obj.file, 'utf8', (error, body) ->
        __parse(body, resolver)

    ###*
     * If an object is passed, adds object
     * to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    data = (obj, resolver) ->
      resolver.resolve(obj.data)

    ###*
     * Takes object and adds to records object in config.locals
     * @param {String} key - the record key
     * @param {Object} object - the key's parameters
     * @param {Object} response - the object to add
     ###

    respond = (key, obj, response) ->
      response = if obj.hook then obj.hook(response) else response
      @roots.config.locals.records[key] = response

    ###*
     * Promises to compile single views for a given collection using a template
     * and saves to the path given by the out_fn
     * @param {Array} collection - the collection from which to create single
     * views
     * @param {String} template - path to the template to use
     * @param {Function} out_fn - returns the path to save the output file given
     * each item
    ###

    compile_single_views = (collection, template, out_fn) ->
      if not _.isArray(collection)
        throw new Error "collection must return an array"

      W.map collection, (item) =>
        @roots.config.locals.item = item
        template_path = path.join(
          @roots.root,
          if _.isFunction(template) then template(item) else template
        )
        compiled_file_path = "#{out_fn(item)}.html"
        _path = "/#{compiled_file_path.replace(path.sep, '/')}"
        compiler = _.find @roots.config.compilers, (c) ->
          _.contains(c.extensions, path.extname(template_path).substring(1))
        compiler_options = @roots.config[compiler.name] ? {}

        compiler.renderFile(
          template_path,
          _.extend(
            @roots.config.locals,
            compiler_options,
            _path: _path
          )).then((res) => @util.write(compiled_file_path, res.result))

    __parse = (response, resolver) ->
      try
        resolver.resolve(JSON.parse(response))
      catch error
        resolver.reject(error)
