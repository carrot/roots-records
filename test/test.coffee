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
  data_hook: path.join(_roots, "data_hook"),
  invalid_key: path.join(_roots, "invalid_key"),
  invalid_url: path.join(_roots, "invalid_url"),
  invalid_file: path.join(_roots, "invalid_file")
  single_view: path.join(_roots, "single_view")
  invalid_collection: path.join(_roots, "invalid_collection")
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

  describe 'data hook', ->
    before (done) ->
      @_ = init_roots _projects.data_hook, done

    it 'should call the hook fn to manipulate the data before passing into views', ->
      @_.helpers.file.contains(path.join("public", "index.html"), JSON.stringify({foo: 'doge'})).should.be.ok

  describe 'single page views', ->
    before (done) ->
      @_ = init_roots _projects.single_view, done
      @test_path = path.join("public", "books", "to-kill-a-mockingbird.html")
      @test_path_dynamic = path.join("public", "tvshows", "fringe.html")

    it 'should compile a single page view', ->
      @_.helpers.file.exists(@test_path).should.be.true

    it 'should pass the correct locals for that single view', ->
      @_.helpers.file.contains(@test_path, 'Harper Lee').should.be.true

    it 'should pass the _path view helper for that single view', ->
      @_.helpers.file.contains(@test_path, '/books/to-kill-a-mockingbird.html')

    it "should use the adapter config settings like 'pretty:true'", ->
      @_.helpers.file.contains(@test_path, '\n').should.be.true

    it 'should compile with a dynamic template path', ->
      @_.helpers.file.contains(@test_path_dynamic, 'dynamic').should.be.true

    it 'should throw an error if collection is not an array', (done) ->
      new Roots(_projects.invalid_collection).compile()
        .catch(should.exist)
        .done(done())
