path  = require 'path'
http  = require 'http'
https = require 'https'
url   = require 'url'
fs    = require 'fs'
_     = require 'lodash'

class Records

  constructor: (selector, options = {}) ->
    this.selector = selector
    this.options = options
    @_determine()

  to: (path) ->
    console.log this.response

  _determine: ->
    switch this.selector.constructor
      when String
        @constructor._parseString this.selector, this.options
      when Object, Array
        @constructor._parseObject this.selector, this.options

  _setup: ->
    @to this.options.path or '/'

  @_parseString: (string, options) ->
    if @_is_valid_url string
      @_parseURL string, options
    else
      @_parsePath string, options

  @_parseURL: (string, options) ->
    url  = url.parse string

    if url.protocol is "https:"
      requester  = https
    else
      requester  = http

    json = ""

    request = requester.request _.merge(url, options), (response) ->
      response.on "data", (chunk) ->
        json += chunk
      response.on "end", ->
        json = Records._parseJSON json

    request.end()
    json

  @_parseObject: (obj, options) ->
    console.log "object"

  @_parseJSON: (json) ->
    try
      JSON.parse json
    catch
      {}

  @_is_valid_url: (str) ->
    url  = url.parse str
    url.protocol? and url.host? and url.path?


module.exports = Records
