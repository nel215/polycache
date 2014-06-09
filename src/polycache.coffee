"use strict"

deferred        = require "deferred"

Memory          = require "./drivers/memory"
File            = require "./drivers/file"
Redis           = require "./drivers/redis"
Memcached       = require "./drivers/memcached"

module.exports = class PolyCache
  @File:        File
  @Redis:       Redis
  @Memory:      Memory
  @Memcached:   Memcached

  constructor: (conf = {})->
    @drivers =
      Memory: new Memory()

    if conf.memcached
      @drivers.Memcached = new Memcached(conf.memcache.host)
    if conf.redis
      @drivers.Redis = new Redis(host: conf.redis.host, port: conf.redis.port)
    if conf.file
      @drivers.File  = new File(dir: conf.file.dir)

    @_rules = []
    @_knownKeys = {}

  addRule: (driver, rule)->
    @_rules.push {driver, rule}

  compareObject: (val, obj)->
    if obj.lt?
      return false if val.length > obj.lt
    if obj.gt?
      return false if val.length < obj.gt
    if obj.lte?
      return false if val.length >= obj.lte
    if obj.gte?
      return false if val.length <= obj.gte

    return true

  getDriver: (key, val, opt)->
    driverName = PolyCache.Memory.name
    for {driver, rule} in @_rules
      # console.log driver, rule
      if key?
        if rule.key instanceof RegExp
          return driver.name if rule.key.test(key)
        else if typeof rule.key is "string"
          return driver.name if rule.key is key
        else if typeof rule.key is "object"
          return driver.name if @compareObject(key, rule.key)
      if val?
        if typeof rule.val is "number"
          return driver.name if val.length is val
        else if typeof rule.val is "object"
          return driver.name if @compareObject(val, rule.val)

    return driverName

  get: (key, opt)->
    driver = @_knownKeys[key] or @getDriver(key, null, opt)
    @drivers[driver].get(key, opt)

  set: (key, val, opt)->
    driver = @_knownKeys[key] = @getDriver(key, val, opt)
    @drivers[driver].set(key, val, opt)

  getAndSet: (key, getCall, opt)->

  del: (key, opt)->
    driver = @_knownKeys[key] or @getDriver(key, null, opt)
    @drivers[driver].del(key, opt)

  end: ()->
    deferred.map((driver for name, driver of @drivers), (driver)->
      driver.end()
    )
