"use strict"

deferred        = require "deferred"
Memcached_      = require "memcached"

module.exports = class Memcached
  constructor: (@host, @options)->
    @client = new Memcached_(@host, @options)
    @client.on 'error', (err)->
      throw err

  get: (key)->
    d = deferred()
    @client.get(key, (err, val)->
      return d.reject(err) if err
      d.resolve(val)
    )
    d.promise

  set: (key, val)->
    d = deferred()
    _val = val
    if typeof val isnt 'string'
      _val = JSON.stringify val
    @client.set(key, _val, (err)->
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
