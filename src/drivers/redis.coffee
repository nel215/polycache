"use strict"

deferred        = require "deferred"
Redis_          = require "redis"
msgpack         = require "msgpack"

module.exports = class Redis
  constructor: (config = {})->
    @client = Redis_.createClient(
      +config.port or 6379
      config.host or "localhost"
    )
    @client.on 'error', (err)->
      throw err

  get: (key)->
    d = deferred()
    @client.get(key, (err, val)->
      return d.resolve(null) unless val?
      if val[0] is "[" or val[0] is "{"
        val = JSON.parse(val)
      else
        val = JSON.parse("[#{val}]")

      d.resolve msgpack.unpack(new Buffer(val))
    )
    d.promise

  set: (key, val)->
    d = deferred()
    @client.set(key, msgpack.pack(val).toJSON().toString(), (err)->
      return d.reject(err) if err
      d.resolve(val)
    )
    d.promise

  del: (key)->
    d = deferred()
    @client.del(key, (err)->
      return d.reject(err) if err
      d.resolve()
    )
    d.promise

  close: ()->
    deferred @client.end()
