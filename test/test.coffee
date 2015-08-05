path      = require "path"
fs        = require "fs"
RootsUtil = require 'roots-util'
h         = new RootsUtil.Helpers(base: _path)

# setup, teardown, and utils

compile_fixture = (fixture_name, done) ->
  @public = path.join(fixture_name, 'public')
  h.project.compile(Roots, fixture_name).done(done)

before (done) ->
  h.project.install_dependencies('*', done)

after ->
  h.project.remove_folders('**/public')

# tests

describe 'url', ->

  it 'records should be present and populated', (done) ->
    compile_fixture.call @, 'url', =>
      index_path = path.join(_path, @public, 'index.html')
      json = JSON.parse(fs.readFileSync(index_path, 'utf8'))

      json.should.be.a('object')
      json.items.should.exist
      json.items.length.should.equal(10)

      done()

describe 'url with http options', ->

  it 'should POST request and generate an error', (done) ->
    project = new Roots(path.join(_path, 'url_options'))
    project.on('error', ->)
    project.compile().catch (res) ->
      if res.error.code is 'ECONNREFUSED' then done() else done(res)

describe 'file', ->

  it 'records should be present and populated', (done) ->
    compile_fixture.call @, 'file', =>
      index_path = path.join(_path, @public, 'index.html')
      json = JSON.parse(fs.readFileSync(index_path, 'utf8'))

      json.should.be.an('array')
      json[0].title.should.equal("The Great Gatsby")

      done()

describe 'data', ->

  it 'records should be present and populated', (done) ->
    compile_fixture.call @, 'data', =>
      index_path = path.join(_path, @public, 'index.html')
      json = JSON.parse(fs.readFileSync(index_path, 'utf8'))

      json.foo.should.equal('bar')

      done()

describe 'multiple records', ->

  it 'should resolve all records if there are more than one', (done) ->
    compile_fixture.call @, 'multiple_records', =>
      index_path = path.join(_path, @public, 'index.html')
      json = JSON.parse(fs.readFileSync(index_path, 'utf8'))

      json.books.length.should.equal(1)
      json.doges.length.should.equal(2)

      done()

describe 'errors', ->

  it 'should error if no keys are provided', (done) ->
    project = new Roots(path.join(_path, 'invalid_key'))
    project.on('error', ->)
    project.compile().catch (res) ->
      res.message.should.equal("You must provide a 'url', 'file', or 'data' key")
      done()

  it 'should error if file is not found', (done) ->
    project = new Roots(path.join(_path, 'invalid_file'))
    project.on('error', ->)
    project.compile().catch (res) ->
      res.message.should.match(/ENOENT/)
      done()

  it 'should error if url does not resolve', (done) ->
    project = new Roots(path.join(_path, 'invalid_url'))
    project.on('error', ->)
    project.compile().catch (res) ->
      res.message.should.equal("URL has not returned any content")
      done()

  it 'should error if url does not return json', (done) ->
    project = new Roots(path.join(_path, 'no_json_url'))
    project.on('error', ->)
    project.compile().catch (res) ->
      res.message.should.equal("URL did not return JSON")
      done()

  it 'should error if data provided is not json', (done) ->
    project = new Roots(path.join(_path, 'invalid_data'))
    project.on('error', ->)
    project.compile().catch (res) ->
      res.message.should.equal("Data provided is a string but must be an object")
      done()

describe 'hook', ->
  it 'hook function should manipulate data'

describe 'single views', ->
  it 'should error if template is provided but not out'
  it 'should error if out is provided but not template'
  it 'should error if data is not an array and template + out are present'
  it 'should resolve template if it is a function or string'
  it 'should include all locals in single post views'
  it 'should repsect compiler options when compiling single post views'
  it 'should include all other records in single post views'
  it 'should include the correct "item" local in single post views'
