fs        = require 'fs'
request   = require 'request'
W         = require 'when'
nodefn    = require 'when/node'

module.exports = (opts) ->

  class Records

    constructor: (@roots) ->
      @roots.config.locals ||= {}
      @__records = {}

    compile_hooks: =>

      before_file: (ctx) =>
        roots  = ctx.roots
        if !roots.records?
          roots.records ||= []
          for key, obj of opts
            roots.records.push(_get.call(@, key, obj))
        W.all(roots.records)

      before_pass: (ctx) =>
        roots   = ctx.file.roots
        config  = roots.config
        locals  = config.locals
        locals.records = @__records

    _get = (key, obj) ->
      if obj.url?
        return _url.call(@, key, obj)
      else if obj.file?
        return _file.call(@, key, obj)
      else if obj.data?
        return _data.call(@, key, obj)
      else
        throw new Error "A valid key is required"

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
      @__records[key] = _to(json, obj.path)

    _to = (json, path) ->
      return json if !path?
      keys = path.split "/"
      pos = json
      for key in keys
        pos = pos[key] unless !pos[key]?
      return pos
