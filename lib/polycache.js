"use strict";
var File, Memcached, Memory, PolyCache, Redis, deferred;

deferred = require("deferred");

Memory = require("./drivers/memory");

File = require("./drivers/file");

Redis = require("./drivers/redis");

Memcached = require("./drivers/memcached");

module.exports = PolyCache = (function() {
  PolyCache.File = File;

  PolyCache.Redis = Redis;

  PolyCache.Memory = Memory;

  PolyCache.Memcached = Memcached;

  function PolyCache(conf) {
    if (conf == null) {
      conf = {};
    }
    this.drivers = {
      Memory: new Memory()
    };
    if (conf.memcached) {
      this.drivers.Memcached = new Memcached(conf.memcache.host);
    }
    if (conf.redis) {
      this.drivers.Redis = new Redis({
        host: conf.redis.host,
        port: conf.redis.port
      });
    }
    if (conf.file) {
      this.drivers.File = new File({
        dir: conf.file.dir
      });
    }
    this._rules = [];
    this._knownKeys = {};
  }

  PolyCache.prototype.addRule = function(driver, rule) {
    return this._rules.push({
      driver: driver,
      rule: rule
    });
  };

  PolyCache.prototype.compareObject = function(val, obj) {
    if (obj.lt != null) {
      if (val.length > obj.lt) {
        return false;
      }
    }
    if (obj.gt != null) {
      if (val.length < obj.gt) {
        return false;
      }
    }
    if (obj.lte != null) {
      if (val.length >= obj.lte) {
        return false;
      }
    }
    if (obj.gte != null) {
      if (val.length <= obj.gte) {
        return false;
      }
    }
    return true;
  };

  PolyCache.prototype.getDriver = function(key, val, opt) {
    var driver, driverName, rule, _i, _len, _ref, _ref1;
    driverName = PolyCache.Memory.name;
    _ref = this._rules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], driver = _ref1.driver, rule = _ref1.rule;
      if (key != null) {
        if (rule.key instanceof RegExp) {
          if (rule.key.test(key)) {
            return driver.name;
          }
        } else if (typeof rule.key === "string") {
          if (rule.key === key) {
            return driver.name;
          }
        } else if (typeof rule.key === "object") {
          if (this.compareObject(key, rule.key)) {
            return driver.name;
          }
        }
      }
      if (val != null) {
        if (typeof rule.val === "number") {
          if (val.length === val) {
            return driver.name;
          }
        } else if (typeof rule.val === "object") {
          if (this.compareObject(val, rule.val)) {
            return driver.name;
          }
        }
      }
    }
    return driverName;
  };

  PolyCache.prototype.get = function(key, opt) {
    var driver;
    driver = this._knownKeys[key] || this.getDriver(key, null, opt);
    return this.drivers[driver].get(key, opt);
  };

  PolyCache.prototype.set = function(key, val, opt) {
    var driver;
    driver = this._knownKeys[key] = this.getDriver(key, val, opt);
    return this.drivers[driver].set(key, val, opt);
  };

  PolyCache.prototype.getAndSet = function(key, getCall, opt) {};

  PolyCache.prototype.del = function(key, opt) {
    var driver;
    driver = this._knownKeys[key] || this.getDriver(key, null, opt);
    return this.drivers[driver].del(key, opt);
  };

  PolyCache.prototype.end = function() {
    var driver, name;
    return deferred.map((function() {
      var _ref, _results;
      _ref = this.drivers;
      _results = [];
      for (name in _ref) {
        driver = _ref[name];
        _results.push(driver);
      }
      return _results;
    }).call(this), function(driver) {
      return driver.end();
    });
  };

  return PolyCache;

})();
