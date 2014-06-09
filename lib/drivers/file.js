"use strict";
var File, Path, deferred, fs, mkdirp, uuid;

deferred = require("deferred");

fs = require("fs");

Path = require("path");

uuid = require("uuid");

mkdirp = require("mkdirp");

module.exports = File = (function() {
  function File(config) {
    if (config == null) {
      config = {};
    }
    this.id = uuid();
    this.filedir = Path.join(config.dir || "/tmp", this.id);
    mkdirp.sync(this.filedir);
  }

  File.prototype.get = function(key) {
    var d;
    d = deferred();
    fs.readFile(Path.join(this.filedir, key), "utf8", function(err, data) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(data);
    });
    return d.promise;
  };

  File.prototype.set = function(key, val) {
    var d, _val;
    d = deferred();
    _val = val;
    if (typeof val !== 'string') {
      _val = JSON.stringify(val);
    }
    fs.writeFile(Path.join(this.filedir, key), _val, {
      encoding: "utf8"
    }, function(err) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(val);
    });
    return d.promise;
  };

  File.prototype.del = function(key) {
    var d;
    d = deferred();
    fs.unlink(Path.join(this.filedir, key), function(err) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(true);
    });
    return d.promise;
  };

  File.prototype.end = function() {
    return this.removeFileRec(this.filedir);
  };

  File.prototype.removeFileRec = function(path) {
    var d, files;
    d = deferred();
    files = fs.readdir(path, function(err, files) {
      files.filter(function(f) {
        return !f.match(/^\.+$/);
      }).forEach(function(file) {
        console.log(file);
        return fs.unlinkSync(Path.join(path, file));
      });
      return fs.rmdir(path, function(err) {
        return d.resolve();
      });
    });
    return d.promise;
  };

  return File;

})();
