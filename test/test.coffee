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

  before (done) ->
    compile_fixture.call @, 'basic', =>
      index_path = path.join(_path, @public, 'index.html')
      @json = JSON.parse(fs.readFileSync(index_path, 'utf8'))
      done()

  it 'records should be present and populated', ->
    @json.should.be.a('object')
    @json.items.should.exist
    @json.items.length.should.equal(10)

describe 'file', ->

  before (done) ->
    compile_fixture.call @, 'file', =>
      index_path = path.join(_path, @public, 'index.html')
      @json = JSON.parse(fs.readFileSync(index_path, 'utf8'))
      done()

  it 'records should be present and populated', ->
    @json.should.be.an('array')
    @json[0].title.should.equal("The Great Gatsby")

describe 'data', ->

  before (done) ->
    compile_fixture.call @, 'data', =>
      index_path = path.join(_path, @public, 'index.html')
      @json = JSON.parse(fs.readFileSync(index_path, 'utf8'))
      done()

  it 'records should be present and populated', ->
    @json.foo.should.equal('bar')

describe 'url with http options', ->
  it 'records should be present and populated'

describe 'multiple records', ->
  it 'should resolve all records if there are more than one'

describe 'errors', ->
  it 'should error if no keys are provided'
  it 'should error if file is not found'
  it 'should error if url does not resolve'
  it 'should error if data provided is not json'

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
