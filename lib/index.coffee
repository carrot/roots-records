fs        = require 'fs'
request   = require 'request'
W         = require 'when'
nodefn    = require 'when/node'

module.exports = (opts) ->

  class Records

    constructor: (@roots) ->
      @ran = false

    compile_hooks: ->
      before_file: (ctx) =>
        if @ran then return
        p = []
        for key, obj of opts
          p.push _process.call(@, key, obj)
        @ran = true
        W.all(p)

    _process = (key, obj) ->
      if obj.url?
        return _url.call(@, key, obj)
      else if obj.file?
        return _file.call(@, key, obj)
      else if obj.data?
        return _data.call(@, key, obj)

    _url = (key, obj) ->
      nodefn.call(request, obj.url)
        .tap (response) =>
          _respond.call(@, key, obj, JSON.parse(response[0].body))

    _file = (key, obj) ->
      W ->
        f = fs.readFileSync obj.file, 'utf8'
        _respond.call(@, key, obj, JSON.parse(f))

    _data = (key, obj) ->
      W ->
        _respond.call(@, key, obj, obj.data)

    _respond = (key, obj, json) ->
      @roots.config.locals ||= {}
      @roots.config.locals.records ||= {}
      @roots.config.locals.records[key] = json

    # _to = (json, path) ->
    #   keys = path.split "/" if path?
    #   pos = json
    #   for key of keys
    #     pos = pos[key]
    #   console.log pos
    #   return pos
