fs        = require 'fs'
request   = require 'request'
W         = require 'when'
nodefn    = require 'when/node'

module.exports = (opts) ->

  class Records

    constructor: (@roots) ->
      @ran = false

    compile_hooks: ->
      before_file: (ctx) ->
        if @ran then return
        p = []
        for key, obj of opts
          p.push _process(ctx.roots, key, obj)
        @ran = true
        W.all(p)

    _process = (roots, key, obj) ->
      if obj.url?
        return _url roots, key, obj
      else if obj.file?
        return _file roots, key, obj
      else if obj.data?
        return _data roots, key, obj

    _url = (roots, key, obj) ->
      nodefn.call(request, obj.url)
        .tap (response) ->
          _respond(roots, key, obj, JSON.parse(response[0].body))

    _file = (roots, key, obj) ->
      W ->
        f = fs.readFileSync obj.file, 'utf8'
        _respond(roots, key, obj, JSON.parse(f))

    _data = (roots, key, obj) ->
      W ->
        _respond(roots, key, obj, obj.data)

    _respond = (roots, key, obj, json) ->
      roots.config.locals ||= {}
      roots.config.locals.records ||= {}
      roots.config.locals[key] = _to json, (obj.path or "/")

    _to = (json, path) ->
      keys = path.split "/"
      pos = json
      pos = pos[key] for key in keys
      return pos
