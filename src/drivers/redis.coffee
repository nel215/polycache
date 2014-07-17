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
        val = msgpack.unpack(new Buffer(JSON.parse("[#{val}]")))

      d.resolve val
    )
    d.promise

  set: (key, val, opt = {})->
    d = deferred()
    @client.set(key, msgpack.pack(val).toJSON().toString(), (err)=>
      unless opt.expire? or opt.expireat?
        return d.reject(err) if err
        return d.resolve(val)
      else
        call = if opt.expire? then "expire" else "expireat"
        time = if opt.expire? then (0|opt.expire / 1000) else (0|opt.expireat / 1000)

        @client[call](key, time, (err)->
          return d.reject(err) if err
          return d.resolve(val)
        )
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
