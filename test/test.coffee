Roots      = require "roots"
path       = require "path"
should     = require "should"
fs         = require "fs"
glob       = require "glob"
W          = require "when"
nodefn     = require "when/node"
run        = require("child_process").exec
_fixtures  = path.join(__dirname, 'fixtures')
RootsUtil  = require "roots-util"
_roots     = path.join(_fixtures, 'roots')
_projects  = {
  url: path.join(_roots, "url"),
  file: path.join(_roots, "file"),
  data: path.join(_roots, "data"),
  invalid_key: path.join(_roots, "invalid_key"),
  invalid_url: path.join(_roots, "invalid_url"),
  invalid_file: path.join(_roots, "invalid_file")
}

init_roots = (base_path, done) ->
  roots = new Roots(base_path)
  roots.on('error', done).on('done', -> done())
  roots.compile()
  { roots: roots, helpers: new RootsUtil.Helpers(base: base_path) }

describe 'records', ->

  before (done) ->
    helpers = new RootsUtil.Helpers(base: _fixtures)
    helpers.project.install_dependencies("*/*", done)

  describe 'url', ->

    before (done) ->
      @_ = init_roots _projects.url, done

    describe 'locals object', ->

      it "should contain 'records' key", ->
        @_.roots.config.locals.should.have.property("records")

      describe "records object", ->

        it "should contain 'books' key", ->
          @_.roots.config.locals.records.should.have.property("books")

    describe 'compiled template', ->

      it "should contain 'books'", ->
        @_.helpers.file.contains(path.join("public", "index.html"), "books").should.be.ok

  describe 'file', ->

    before (done) ->
      @_ = init_roots _projects.file, done

    describe 'locals object', ->

      it "should contain 'records' key", ->
        @_.roots.config.locals.should.have.property("records")

      describe "records object", ->

        it "should contain 'books' key", ->
          @_.roots.config.locals.records.should.have.property("books")

    describe 'compiled template', ->

      it "should have {foo: 'bar'} json", ->
        @_.helpers.file.contains(path.join("public", "index.html"), JSON.stringify({foo: "bar"})).should.be.ok

  describe 'data', ->

    before (done) ->
      @_ = init_roots _projects.data, done

    describe 'locals object', ->

      it "should contain 'records' key", ->
        @_.roots.config.locals.should.have.property("records")

      describe "records object", ->

        it "should contain 'books' key", ->
          @_.roots.config.locals.records.should.have.property("books")

    describe 'compiled template', ->

      it "should have {foo: 'bar'} json", ->
        @_.helpers.file.contains(path.join("public", "index.html"), JSON.stringify({foo: "bar"})).should.be.ok

  describe 'invalid key', ->

    it 'should throw an error', (done) ->
      new Roots(_projects.invalid_key).compile()
        .done(done(), should.exist)

  describe 'invalid url', ->

    it 'should throw an error', (done) ->
      new Roots(_projects.invalid_url).compile()
        .catch()
        .done(done())

  describe 'invalid file', ->

    it 'should throw an error', (done) ->
      new Roots(_projects.invalid_file).compile()
        .catch(should.exist)
        .done(done())
