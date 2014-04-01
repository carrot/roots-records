fs        = require 'fs'
request   = require 'request'
path      = require 'path'
W         = require 'when'
nodefn    = require 'when/node'

module.exports = (opts) ->

  class Records

    ###*
     * Creates a locals object if one isn't set and
     * creates a records object to store results.
     * @constructor
     ###

    constructor: (@roots) ->
      @roots.config.locals ||= {}
      @__records ||= {}

    compile_hooks: =>

      before_file: (ctx) =>
        roots  = ctx.roots
        if !roots.records?
          roots.records ||= []
          for key, obj of opts
            roots.records.push(get.call(@, key, obj))
        W.all(roots.records)

      before_pass: (ctx) =>
        return if @roots.config.locals.records?
        @roots.config.locals.records = @__records

    ###*
     * Determines and calls the appropriate function
     * for retrieving json based on keys in object.
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
    ###

    get = (key, obj) ->
      if obj.url?
        return url.call(@, key, obj)
      else if obj.file?
        return file.call(@, key, obj)
      else if obj.data?
        return data.call(@, key, obj)
      else
        throw new Error "A valid key is required"

    ###*
     * Runs http request for json if URL is passed,
     * adds result to records, and returns a promise.
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
     ###

    url = (key, obj) ->
      nodefn.call(request, obj.url)
        .tap (response) =>
          respond.call(@, key, obj, JSON.parse(response[0].body))

    ###*
     * Reads a file if a path is passed, adds result
     * to records, and returns a promise.
     * @param {string} key - the record key
     * @param {object} obj - the key's parameters
     ###

    file = (key, obj) ->
      f = fs.readFileSync obj.file, 'utf8'
      respond.call(@, key, obj, JSON.parse(f))

    ###*
     * If an object is passed, adds object
     * to records, and returns a promise.
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
     ###

    data = (key, obj) ->
      respond.call(@, key, obj, obj.data)

    ###*
     * Takes json and adds to records object
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
     * @params {Object} json - the json result
     ###

    respond = (key, obj, json) ->
      @__records[key] = to(json, obj.path)

    ###*
     * Navigates object based on "path."
     * ex: 'book/items' returns obj['books']['items']
     * @param {String} key - the json to be navigated
     * @param {Object} path - the path to the desired value.
     ###

    to = (json, path) ->
      if not path then return json
      keys  = path.split "/"
      pos   = json
      pos   = pos[key] for key in keys when pos[key]?
      return pos
