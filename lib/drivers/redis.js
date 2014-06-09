"use strict";
var Redis, Redis_, deferred;

deferred = require("deferred");

Redis_ = require("redis");

module.exports = Redis = (function() {
  function Redis(config) {
    if (config == null) {
      config = {};
    }
    this.client = Redis_.createClient(+config.port || 6379, config.host || "localhost");
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
    return deferred(this.client.end());
  };

  return Redis;

})();
