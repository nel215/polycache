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
    deferred(do ->
      delete @memory[key]
      return
    )

  end: ()->
    deferred(
      delete @memory
    )
