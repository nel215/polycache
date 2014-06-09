"use strict";
var Redis, deferred;

deferred = require("deferred");

Redis = require("redis");

module.exports = Redis = (function() {
  function Redis(_arg) {
    var host, port;
    port = _arg.port, host = _arg.host;
    this.client = Redis.createClient(port || 6379, host);
    this.client.on('error', function(err) {
      throw err;
    });
  }

  Redis.prototype.get = function(key) {
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

  Redis.prototype.set = function(key, val) {
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

  Redis.prototype.del = function(key) {
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

  Redis.prototype.end = function() {
    return deferred((function() {
      return this.client.end();
    })());
  };

  return Redis;

})();
