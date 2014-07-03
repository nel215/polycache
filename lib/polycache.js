"use strict";
var Fs, Path, PolyCache, deferred, driver, drivers, driversDir, ext, name, _i, _len, _ref;

deferred = require("deferred");

Fs = require("fs");

Path = require("path");

module.exports = PolyCache = (function() {
  function PolyCache(conf, userDrivers) {
    var c, driver, name, _i, _len;
    if (conf == null) {
      conf = {};
    }
    if (userDrivers == null) {
      userDrivers = {};
    }
    this.drivers = {
      Memory: new PolyCache.Memory()
    };
    for (name in PolyCache) {
      if (c = conf[name.toLowerCase()]) {
        this.drivers[name] = new PolyCache[name](c);
      }
    }
    for (driver = _i = 0, _len = userDrivers.length; _i < _len; driver = ++_i) {
      name = userDrivers[driver];
      if (c = conf[name.toLowerCase()]) {
        this.drivers[name] = typeof driver === "string" ? new require(driver)(c) : new driver(c);
      }
    }
    this._rules = [];
    this._knownKeys = {};
    this.defaultDriver = conf.defaultDriver || PolyCache.Memory;
    this.noCache = (process.env.NO_CACHE != null) || conf.noCache || false;
  }

  PolyCache.prototype.addRule = function(driver, rule) {
    return this._rules.push({
      driver: driver,
      rule: rule
    });
  };

  PolyCache.prototype.compareObject = function(val, cond) {
    if (cond.lt != null) {
      if (val.length > cond.lt) {
        Return(false);
      }
    }
    if (cond.gt != null) {
      if (val.length < cond.gt) {
        return false;
      }
    }
    if (cond.lte != null) {
      if (val.length >= cond.lte) {
        return false;
      }
    }
    if (cond.gte != null) {
      if (val.length <= cond.gte) {
        return false;
      }
    }
    return true;
  };

  PolyCache.prototype.getDriver = function(key, val, opt) {
    var driver, rule, _i, _len, _ref, _ref1;
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
    return this.defaultDriver.name;
  };

  PolyCache.prototype.get = function(key, opt) {
    var driver;
    if (this.noCache) {
      return null;
    }
    driver = this._knownKeys[key] || this.getDriver(key, null, opt);
    return this.drivers[driver].get(key, opt);
  };

  PolyCache.prototype.set = function(key, val, opt) {
    var driver;
    driver = this._knownKeys[key] = this.getDriver(key, val, opt);
    return this.drivers[driver].set(key, val, opt);
  };

  PolyCache.prototype.getAndSet = function(key, getCall, opt) {
    var driver;
    driver = this._knownKeys[key] || this.getDriver(key, null, opt);
    return deferred(this.noCache ? null : this.drivers[driver].get(key, opt)).then((function(_this) {
      return function(val) {
        if (val != null) {
          return val;
        }
        return getCall().then(function(val) {
          return _this.drivers[driver].set(key, val, opt);
        });
      };
    })(this));
  };

  PolyCache.prototype.del = function(key, opt) {
    var driver;
    driver = this._knownKeys[key] || this.getDriver(key, null, opt);
    return this.drivers[driver].del(key, opt);
  };

  PolyCache.prototype.close = function() {
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
      return driver.close();
    });
  };

  return PolyCache;

})();

driversDir = Path.join(__dirname, "drivers");

drivers = Fs.readdirSync(driversDir).filter(function(f) {
  return !f.match(/^\.+$/);
});

for (_i = 0, _len = drivers.length; _i < _len; _i++) {
  driver = drivers[_i];
  _ref = driver.split("."), name = _ref[0], ext = _ref[1];
  PolyCache[name[0].toUpperCase() + name.slice(1)] = require(Path.join(driversDir, name));
}
