"use strict"

deferred        = require "deferred"

module.exports = class Memory
  constructor: ->
    @memory = {}

  get: (key)->
    deferred(do =>
      @memory[key]
    )

  set: (key, val)->
    deferred(do =>
      @memory[key] = val
    )

  del: (key)->
    deferred(->
      delete @memory[key]
      return
    )

  close: ()->
    deferred(
      delete @memory
    )
