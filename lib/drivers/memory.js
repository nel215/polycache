"use strict";
var Memory, deferred;

deferred = require("deferred");

module.exports = Memory = (function() {
  function Memory() {
    this.memory = {};
  }

  Memory.prototype.get = function(key) {
    return deferred((function(_this) {
      return function() {
        return _this.memory[key];
      };
    })(this)());
  };

  Memory.prototype.set = function(key, val) {
    return deferred((function(_this) {
      return function() {
        return _this.memory[key] = val;
      };
    })(this)());
  };

  Memory.prototype.del = function(key) {
    return deferred(function() {
      delete this.memory[key];
    });
  };

  Memory.prototype.close = function() {
    return deferred(delete this.memory);
  };

  return Memory;

})();
