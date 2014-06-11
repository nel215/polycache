"use strict";
var Redis, Redis_, deferred, msgpack;

deferred = require("deferred");

Redis_ = require("redis");

msgpack = require("msgpack");

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
      if (val == null) {
        return d.resolve(null);
      }
      if (val[0] === "[" || val[0] === "{") {
        val = JSON.parse(val);
      } else {
        val = msgpack.unpack(new Buffer(JSON.parse("[" + val + "]")));
      }
      return d.resolve(val);
    });
    return d.promise;
  };

  Redis.prototype.set = function(key, val) {
    var d;
    d = deferred();
    this.client.set(key, msgpack.pack(val).toJSON().toString(), function(err) {
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

  Redis.prototype.close = function() {
    return deferred(this.client.end());
  };

  return Redis;

})();
