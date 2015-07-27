fs        = require 'fs'
rest      = require 'rest'
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
      fetch_records = (get(key, conf) for key, conf of opts)

      W.all(fetch_records).with(@)
        .then (res) -> W.map(res, apply_hook)
        .tap (res) -> W.map(res, add_to_locals.bind(@))
        .tap (res) -> W.map(res, compile_single_views.bind(@))

    ###*
     * Promises to retrieve data, then
     * stores object in locals hash
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
    ###

    exec = (key, obj) ->
      get(obj).then (res) =>
        respond.call(@, key, obj, res)
      .tap (res) =>
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

    get = (key, opts) ->
      data_promise = switch
        when opts.hasOwnProperty('url') then resolve_url(opts)
        when opts.hasOwnProperty('file') then resolve_file(opts)
        when opts.hasOwnProperty('data') then W.resolve(opts.data)
        else throw new Error("Key must be 'url', 'file', or 'data'")

      data_promise.then (data) -> { key: key, options: opts, data: data }

    ###*
     * Runs http request for json if URL is passed,
     * adds result to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    resolve_url = (opts) ->
      mime = require('rest/interceptor/mime')
      error_code = require('rest/interceptor/errorCode')
      client = rest.wrap(mime).wrap(error_code)

      client_opts = { path: opts.url }

      if opts.method then client_opts.method = opts.method
      if opts.params then client_opts.params = opts.params
      if opts.headers then client_opts.headers = opts.headers
      if opts.entity then client_opts.entity = opts.entity

      client(client_opts).then (res) -> res.entity

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
     * If a hook was provided in the config, runs the response through the hook.
     *
     * @param {String} key - the record key
     * @param {Object} config - the record's config options
     * @param {Object} response - the record's actual data
     ###

    apply_hook = (obj) ->
      if not obj.options.hook then return obj
      obj.data = obj.options.hook(response)
      return obj

    ###*
     * Given a resolved records object, adds it to the view's locals.
     *
     * @param {Object} obj - records object, containing a `key` and `data`
    ###

    add_to_locals = (obj) ->
      @roots.config.locals.records[obj.key] = obj.data

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
