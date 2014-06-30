"use strict";
var File, Path, crypto, deferred, fs, mkdirp, msgpack;

deferred = require("deferred");

fs = require("fs");

Path = require("path");

mkdirp = require("mkdirp");

crypto = require("crypto");

msgpack = require("msgpack");

module.exports = File = (function() {
  function File(config) {
    if (config == null) {
      config = {};
    }
    this.filedir = Path.join(config.dir || "./tmp");
    mkdirp.sync(this.filedir);
  }

  File.prototype.toKey = function(path) {
    return crypto.createHash("sha1").update(path, "ascii").digest("hex");
  };

  File.prototype.get = function(key) {
    var d;
    d = deferred();
    fs.readFile(Path.join(this.filedir, this.toKey(key)), function(err, data) {
      return d.resolve(data != null ? msgpack.unpack(data) : void 0);
    });
    return d.promise;
  };

  File.prototype.set = function(key, val) {
    var d;
    d = deferred();
    fs.writeFile(Path.join(this.filedir, this.toKey(key)), msgpack.pack(val), function(err) {
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
    fs.unlink(Path.join(this.filedir, this.toKey(key)), function(err) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(true);
    });
    return d.promise;
  };

  File.prototype.close = function() {
    return this.removeFileRec(this.filedir);
  };

  File.prototype.removeFileRec = function(path) {
    var d, files;
    d = deferred();
    files = fs.readdir(path, function(err, files) {
      files.filter(function(f) {
        return !f.match(/^\.+$/);
      }).forEach(function(file) {
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
