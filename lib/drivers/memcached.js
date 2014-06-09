"use strict";
var Memcached, deferred;

deferred = require("deferred");

Memcached = require("memcached");

module.exports = Memcached = (function() {
  function Memcached(host, options) {
    this.host = host;
    this.options = options;
    this.client = new Memcached(this.host, this.options);
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

  Memcached.prototype.end = function() {
    return deferred((function() {
      return this.client.end();
    })());
  };

  return Memcached;

})();
