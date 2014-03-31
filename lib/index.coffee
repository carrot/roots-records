fs        = require 'fs'
request   = require 'request'
W         = require 'when'
nodefn    = require 'when/node'

module.exports = (opts) ->

  class Records

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

    get = (key, obj) ->
      if obj.url?
        return url.call(@, key, obj)
      else if obj.file?
        return file.call(@, key, obj)
      else if obj.data?
        return data.call(@, key, obj)
      else
        throw new Error "A valid key is required"

    url = (key, obj) ->
      nodefn.call(request, obj.url)
        .tap (response) =>
          respond.call(@, key, obj, JSON.parse(response[0].body))

    file = (key, obj) ->
      W ->
        f = fs.readFileSync obj.file, 'utf8'
        respond.call(@, key, obj, JSON.parse(f))

    data = (key, obj) ->
      W ->
        respond.call(@, key, obj, obj.data)

    respond = (key, obj, json) ->
      @__records[key] = to(json, obj.path)

    to = (json, path) ->
      if not path then return json
      keys  = path.split "/"
      pos   = json
      pos   = pos[key] for key in keys when pos[key]?
      return pos
