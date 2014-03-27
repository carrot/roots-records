->
  "use strict"

path  = require 'path'
http  = require 'http'
https = require 'https'
url   = require 'url'
fs    = require 'fs'
_     = require 'lodash'

class Records

  constructor: (selector, options = {}) ->
    @selector = selector
    @options = options
    @_parse @_setup.bind(this)

  to: (path) ->
    keys  = path.split "/"
    loc   = @object
    loc   = loc[key] for key in keys
    loc

  _parse: (callback) ->
    switch @selector.constructor
      when String
        @constructor._parseString @selector, @options, callback
      when Object, Array
        @constructor._parseObject @selector, @options, callback

  _setup: (response) ->
    @object  = @constructor._toJSON response
    @to @options.path or "/"

  @_parseString: (string, options, callback) ->
    if @_is_valid_url string
      @_parseURL string, options, callback
    else
      @_parsePath string, options, callback

  @_parseURL: (string, options, callback) ->
    if url.protocol is "https:"
      requester  = https
    else
      requester  = http

    json = ""

    request = requester.request _.merge(url, options.request), (response) ->
      response.on "data", (chunk) ->
        json += chunk
      response.on "end", ->
        callback json

    request.end()

  @_parsePath: (string, options, callback) ->
    json = fs.readFileSync string, 'utf8'
    callback json

  @_is_valid_url: (str) ->
    url  = url.parse str
    url.protocol? and url.host? and url.path?

  @_toJSON: (json) ->
    JSON.parse json


module.exports = Records
