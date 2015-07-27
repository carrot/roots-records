fs        = require 'fs'
rest      = require 'rest'
path      = require 'path'
W         = require 'when'
node      = require 'when/node'
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
      fetch_records = (fetch(key, conf) for key, conf of opts)

      W.all(fetch_records).with(@)
        .then (res) -> W.map(res, apply_hook)
        .tap (res) -> W.map(res, add_to_locals.bind(@))
        .tap (res) -> W.map(res, compile_single_views.bind(@))

    ###*
     * Fetches the JSON data from a url, file, or data and returns it neatly as
     * an object containing the key, options, and resolved data.
     *
     * @param {String} key - name of the record being fetched
     * @param {Object} opts - options provided under the key
     * @returns {Promise|Object} - a promise for an object with a `key`,
     * `options`, and `data` values
    ###

    fetch = (key, opts) ->
      data_promise = switch
        when opts.hasOwnProperty('url') then resolve_url(opts)
        when opts.hasOwnProperty('file') then resolve_file(opts)
        when opts.hasOwnProperty('data') then W.resolve(opts.data)
        else throw new Error("You must provide a 'url', 'file', or 'data' key")

      data_promise.then (data) -> { key: key, options: opts, data: data }

    ###*
     * Makes a request to the provided url, returning the response body as JSON.
     *
     * @param {Object} opts - the key's parameters
     ###

    resolve_url = (opts) ->
      mime = require('rest/interceptor/mime')
      error_code = require('rest/interceptor/errorCode')
      client = rest.wrap(mime).wrap(error_code)

      conf = if typeof opts.url is 'string' then { path: opts.url } else opts
      client(conf).then (res) -> res.entity

    ###*
     * Reads the file based on a path relative to the project root, returns the
     * results as JSON.
     *
     * @param {Object} obj - the key's parameters
     ###

    resolve_file = (opts) ->
      node.call(fs.readFile.bind(fs), path.resolve(opts.file), 'utf8')
        .then (contents) -> JSON.parse(contents)

    ###*
     * If a hook was provided in the config, runs the response through the hook.
     *
     * @param {String} obj - record object with a `key`, `options`, and `data`
     ###

    apply_hook = (obj) ->
      if not obj.options.hook then return obj
      obj.data = obj.options.hook(obj.data)
      return obj

    ###*
     * Given a resolved records object, adds it to the view's locals.
     *
     * @param {Object} obj - records object, containing a `key` and `data`
    ###

    add_to_locals = (obj) ->
      @roots.config.locals.records[obj.key] = obj.data

    ###*
     * This needs to be gutted and refactored still
    ###

    compile_single_views = (obj) ->
      if not obj.template or not obj.out then return

      if obj.template and not obj.out
        throw new Error("You must also provide an 'out' option")
      if obj.out and not obj.template
        throw new Error("You must also provide a 'template' option")

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
