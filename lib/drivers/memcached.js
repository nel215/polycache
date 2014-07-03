"use strict";
var Memcached, Memcached_, deferred;

deferred = require("deferred");

Memcached_ = require("memcached");

module.exports = Memcached = (function() {
  function Memcached(config) {
    if (config == null) {
      config = {};
    }
    this.host = config.host;
    this.options = config.options;
    this.client = new Memcached_(this.host, this.options);
    this.client.on('error', function(err) {
      throw err;
    });
  }

  Memcached.prototype.get = function(key) {
    var d;
    d = deferred();
    this.client.get(key, function(err, val) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(val);
    });
    return d.promise;
  };

  Memcached.prototype.set = function(key, val) {
    var d, _val;
    d = deferred();
    _val = val;
    if (typeof val !== 'string') {
      _val = JSON.stringify(val);
    }
    this.client.set(key, _val, function(err) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve(val);
    });
    return d.promise;
  };

  Memcached.prototype.del = function(key) {
    var d;
    d = deferred();
    this.client.del(key, function(err) {
      if (err) {
        return d.reject(err);
      }
      return d.resolve();
    });
    return d.promise;
  };

  Memcached.prototype.close = function() {
    return deferred(this.client.end());
  };

  return Memcached;

})();
