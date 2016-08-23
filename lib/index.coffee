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
      @roots.config.locals.records ||= {}

    ###*
     * Setup extension method loops through objects and
     * returns a promise to get all data and store.
     ###

    setup: ->
      fetch_records = (fetch.call(@, key, conf) for key, conf of opts)

      W.all(fetch_records)
        .then (res) -> W.map(res, apply_hook)
        .tap (res) => W.map(res, add_to_locals.bind(@))
        .tap (res) => W.map(res, write_hook.bind(@))
        .tap (res) => W.map(res, compile_single_views.bind(@))

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
        when _.has(opts, 'url') then resolve_url(opts)
        when _.has(opts, 'file') then resolve_file.call(@, opts)
        when _.has(opts, 'data') then resolve_data(opts)
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
      client = rest
        .wrap(mime)
        .wrap(error_code)

      if typeof opts.url is 'string'
        conf = { path: opts.url }
      else
        conf = opts.url

      client(conf).then (res) ->
        if not res.entity
          throw new Error("URL has not returned any content")

        if typeof res.entity isnt 'object'
          throw new Error("URL did not return JSON")

        res.entity

    ###*
     * Reads the file based on a path relative to the project root, returns the
     * results as JSON.
     *
     * @param {Object} obj - the key's parameters
     ###

    resolve_file = (opts) ->
      node.call(fs.readFile.bind(fs), path.join(@roots.root, opts.file), 'utf8')
        .then (contents) -> JSON.parse(contents)

    ###*
     * Ensures data provided is an object, then resolves it through.
     *
     * @param {Object} opts - the key's parameters
    ###
    resolve_data = (opts) ->
      type = typeof opts.data
      if type isnt 'object'
        throw new Error("Data provided is a #{type} but must be an object")

      W.resolve(opts.data)

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
     * If a write string option was provided in the config, write out the 
     * retrieved data to the configured file for later usage in the generated
     * site
     *
     * @param {String} obj - record object with a `key`, `options`, and `data`
     ###

    write_hook = (obj) ->
      if not obj.options.write then return
      # Maybe one needs it not only for urls - so ignore this check
      # if not obj.options.url then throw new Error("Writing fetched JSON Data
      # to a file does only make sense on urls, he? So please provide a 'url' 
      # option")
      return this.util.write(opts.write, JSON.stringify(obj.data))

    ###*
     * Given a resolved records object, adds it to the view's locals.
     *
     * @param {Object} obj - records object, containing a `key` and `data`
    ###

    add_to_locals = (obj) ->
      @roots.config.locals.records[obj.key] = obj.data

    ###*
     * Given a records object, if that object has `template` and `out` keys, and
     * its data is an array, iterates through its data, creating a single view
     * for each item in the array using the template provided in the `template`
     * value, and writing to the path provided in the `out` value.
     *
     * @param {Object} obj - record object with a `key`, `options`, and `data`
    ###

    compile_single_views = (obj) ->
      obj_opts = obj.options
      if not obj_opts.template and not obj_opts.out then return

      if obj_opts.template and not obj_opts.out
        throw new Error("You must also provide an 'out' option")
      if obj_opts.out and not obj_opts.template
        throw new Error("You must also provide a 'template' option")
      if not Array.isArray(obj.data)
        throw new Error("'#{obj.key}' data must be an array")

      W.map obj.data, (item) =>
        tpl = if _.isFunction(obj_opts.template)
          obj_opts.template(item)
        else
          obj_opts.template
        tpl_path = path.join(@roots.root, tpl)
        output_path = "#{obj_opts.out(item)}.html"
        compiler = _.find @roots.config.compilers, (c) ->
          _.contains(c.extensions, path.extname(tpl_path).substring(1))
        compiler_opts = _.extend(
          @roots.config.locals,
          @roots.config[compiler.name] ? {},
          _path: output_path,
          { item: item }
        )

        compiler.renderFile(tpl_path, compiler_opts)
          .then (res) => @util.write(output_path, res.result)
