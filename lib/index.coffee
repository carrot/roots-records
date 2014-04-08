fs        = require 'fs'
request   = require 'request'
path      = require 'path'
W         = require 'when'

module.exports = (opts) ->

  class Records

    ###*
     * Creates a locals object if one isn't set.
     * @constructor
     ###

    constructor: (@roots) ->
      @roots.config.locals ||= []
      @roots.config.locals.records ||= []

    ###*
     * Setup extension method loops through objects and
     * returns a promise to get all data and store.
     ###

    setup: ->
      if !@roots.__records
        @roots.__records = []
        for key, obj of opts
          @roots.__records.push exec.call @, key, obj
        W.all @roots.__records

    ###*
     * Promises to retrieve data, then
     * stores object in locals hash
     * @param {String} key - the record key
     * @param {Object} obj - the key's parameters
    ###

    exec = (key, obj) ->
      get obj
        .then (response) =>
          respond.call @, key, obj, response

    ###*
     * Determines and calls the appropriate function
     * for retrieving json based on keys in object.
     * @param {Object} obj - the key's parameters
    ###

    get = (obj) ->

      deferred = W.defer()
      resolver = deferred.resolver
      promise = deferred.promise

      if obj.url?
        url obj, resolver
      else if obj.file?
        file obj, resolver
      else if obj.data?
        data obj, resolver
      else
        throw new Error "A valid key is required"

      return promise

    ###*
     * Runs http request for json if URL is passed,
     * adds result to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    url = (obj, resolver) ->
      request obj.url, (error, response, body) ->
        __parse body, resolver

    ###*
     * Reads a file if a path is passed, adds result
     * to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    file = (obj, resolver) ->
      fs.readFile obj.file, 'utf8', (error, body) ->
        __parse body, resolver

    ###*
     * If an object is passed, adds object
     * to records, and returns a resolution.
     * @param {Object} obj - the key's parameters
     * @param {Function} resolve - function to resolve deferred promise
     ###

    data = (obj, resolver) ->
      resolver
        .resolve obj.data

    ###*
     * Takes object and adds to records object in config.locals
     * @param {String} key - the record key
     * @param {Object} object - the key's parameters
     * @param {Object} response - the object to add
     ###

    respond = (key, obj, response) ->
      @roots.config.locals.records[key] = to response, obj.path

    ###*
     * Navigates object based on "path."
     * ex: 'book/items' returns obj['books']['items']
     * @param {String} object - the object to be navigated
     * @param {Object} path - the path to the desired value.
     ###

    to = (object, path) ->
      if not path then return object
      keys = path.split "/"
      pos = object
      pos = pos[key] for key in keys when pos[key]?
      pos

    __parse = (response, resolver) ->
      try
        resolver.resolve JSON.parse(response)
      catch error
        resolver.reject error
