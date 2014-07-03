"use strict"

deferred        = require "deferred"

Memory          = require "./drivers/memory"
File            = require "./drivers/file"
Redis           = require "./drivers/redis"
Memcached       = require "./drivers/memcached"

# ------------------------------------------------------------
# @class PolyCache
#
module.exports = class PolyCache
  @File:        File
  @Redis:       Redis
  @Memory:      Memory
  @Memcached:   Memcached

  #
  # * @method constructor
  # * @param conf {Object} 設定
  #
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

    @defaultDriver = conf.defaultDriver or PolyCache.Memory
    @noCache = process.env.NO_CACHE? or conf.noCache or false

  #
  # add rules for selecting drivers
  #
  # * @method addRule
  # * @param driver {String} use driver name
  # * @param rule {RegExp or String or Number or Object} condition for apply this driver
  #
  addRule: (driver, rule)->
    @_rules.push {driver, rule}

  #
  # compare value with condition
  #
  # * @method compareObject
  # * @param val{Object} compare target
  # * @param cond{Object} condition to compare
  # * @return {Boolean} result of comparison
  #
  compareObject: (val, cond)->
    if cond.lt?
      Return false if val.length > cond.lt
    if cond.gt?
      return false if val.length < cond.gt
    if cond.lte?
      return false if val.length >= cond.lte
    if cond.gte?
      return false if val.length <= cond.gte

    return true

  #
  # select driver for specified key and val
  #
  # * @method getDriver
  # * @param key{Object} target key
  # * @param val{Object} target value
  # * @param opt{Object} condition to compare
  # * @return {String} driver name
  #
  getDriver: (key, val, opt)->
    for {driver, rule} in @_rules
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

    return @defaultDriver.name

  #
  # get value for key
  #
  # * @method get
  # * @param key{Object} key
  # * @param opt{Object} option
  # * @return {Promise{Object}}
  #
  get: (key, opt)->
    return null if @noCache
    driver = @_knownKeys[key] or @getDriver(key, null, opt)
    @drivers[driver].get(key, opt)

  #
  # set value for key
  #
  # * @method set
  # * @param key{Object} key
  # * @param val{Object} value
  # * @param opt{Object} option
  # * @return {Promise{Object}}
  #
  set: (key, val, opt)->
    driver = @_knownKeys[key] = @getDriver(key, val, opt)
    @drivers[driver].set(key, val, opt)

  #
  # return value for the key when it exists else exec getCall and set the value of it
  #
  # * @method getAndSet
  # * @param key{Object} key
  # * @param getCall{Object} function executed when key doesnot exist
  # * @param opt{Object} option
  # * @return {Promise{Object}}
  #
  getAndSet: (key, getCall, opt)->
    driver = @_knownKeys[key] or @getDriver(key, null, opt)

    deferred(
      if @noCache then null else @drivers[driver].get(key, opt)
    )
    .then((val)=>
      return val if val?

      getCall()
      .then((val)=>
        @drivers[driver].set(key, val, opt)
      )
    )

  #
  # delete key
  #
  # * @method get
  # * @param key{Object} key
  # * @param opt{Object} option
  # * @return {Promise{Object}}
  #
  del: (key, opt)->
    driver = @_knownKeys[key] or @getDriver(key, null, opt)
    @drivers[driver].del(key, opt)

  #
  # close all using drivers
  #
  # * @method close
  # * @return {Promise{Object}}
  #
  close: ()->
    deferred.map((driver for name, driver of @drivers), (driver)->
      driver.close()
    )
