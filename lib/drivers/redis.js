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

  Redis.prototype.set = function(key, val, opt) {
    var d;
    if (opt == null) {
      opt = {};
    }
    d = deferred();
    this.client.set(key, msgpack.pack(val).toJSON().toString(), (function(_this) {
      return function(err) {
        var call, time;
        if (!((opt.expire != null) || (opt.expireat != null))) {
          if (err) {
            return d.reject(err);
          }
          return d.resolve(val);
        } else {
          call = opt.expire != null ? "expire" : "expireat";
          time = opt.expire != null ? 0 | opt.expire / 1000 : 0 | opt.expireat / 1000;
          return _this.client[call](key, time, function(err) {
            if (err) {
              return d.reject(err);
            }
            return d.resolve(val);
          });
        }
      };
    })(this));
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
