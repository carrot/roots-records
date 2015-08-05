var chai = require('chai'),
    chai_fs = require('chai-fs'),
    path = require('path'),
    Roots = require('roots'),
    Util = require('roots-util');

var _path = path.join(__dirname, '../fixtures'),
    h = new Util.Helpers({ base: _path });

var should = chai.should();
chai.use(chai_fs);

global.chai = chai;
global.should = should;
global.h = h;
global._path = _path;
global.Roots = Roots;
