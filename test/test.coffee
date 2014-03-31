Roots      = require "roots"
path       = require "path"
should     = require "should"
fs         = require "fs"
glob       = require "glob"
W          = require "when"
_fixtures  = path.join(__dirname, 'fixtures')
_roots     = path.join(_fixtures, 'roots')
_public    = path.join(_roots, 'public')

should.contain = (path, content) ->
  fs
    .readFileSync path, 'utf8'
    .indexOf content
    .should
    .not
    .equal -1

before (done) ->
  tasks = []
  for d in glob.sync("#{_fixtures}/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks).then -> done()

describe 'records', ->

  before (done) ->
    project = new Roots(_roots)
    project.compile()
      .on 'done', done

  describe 'compiled template', ->

    it "should contain 'books'", ->
      should.contain path.join(_public, "index.html"), "books"

    it "should JSON.parse", ->
      obj  = JSON.parse(fs.readFileSync(path.join(_public, "index.html")))
      obj.should.be.ok
