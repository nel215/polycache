"use strict"

{expect} = require "chai"
deferred = require "deferred"

PolyCache = require "../src/polycache"

describe "PolyChart", ->
  describe "Drivers", ->
    it "memory driver", (done)->
      driver = new PolyCache.Memory()
      expect(driver).to.be.an.instanceof PolyCache.Memory

      driver.end()
      .then(->
        done()
      )
    it "file driver", (done)->
      driver = new PolyCache.File()
      expect(driver).to.be.an.instanceof PolyCache.File

      driver.end()
      .then(->
        done()
      )
    it "redis driver", (done)->
      driver = new PolyCache.Redis()
      expect(driver).to.be.an.instanceof PolyCache.Redis

      driver.end()
      .then(->
        done()
      )
    it "memcached driver", (done)->
      driver = new PolyCache.Memcached()
      expect(driver).be.an.instanceof PolyCache.Memcached

      driver.end()
      .then(->
        done()
      )

  describe "Memory", ->
    cache = new PolyCache()
    it "get and set key, val", (done)->
      cache.set("key", "val")
      .then(->
        cache.get("key")
      )
      .then((val)->
        expect(val).to.be.eql "val"
        done()
      )
      .catch((err)->
        done(err)
      )

    it "getAndSet key, call", (done)->
      cache.getAndSet("key2", ()-> deferred(10))
      .then((val)->
        expect(val).to.be.eql 10
      )
      .then(->
        cache.getAndSet("key2", ()-> deferred(20))
      )
      .then((val)->
        expect(val).to.be.eql 10
      )
      .then(->
        cache.del("key2")
      )
      .then(->
        done()
      )
      .catch((err)->
        done(err)
      )

  describe "File", ->
    cache = new PolyCache(defaultDriver: PolyCache.File, file: {dir: "./tmp"})
    it "get and set key, val", (done)->
      cache.set("key", "val")
      .then(->
        cache.get("key")
      )
      .then((val)->
        expect(val).to.be.eql "val"
        done()
      )
      .catch((err)->
        done(err)
      )

    it "getAndSet key, call", (done)->
      cache.getAndSet("key2", ()-> deferred(10))
      .then((val)->
        expect(val).to.be.eql 10
      )
      .then(->
        cache.getAndSet("key2", ()-> deferred(20))
      )
      .then((val)->
        expect(val).to.be.eql "10"
      )
      .then(->
        cache.del("key2")
      )
      .then(->
        done()
      )
      .catch((err)->
        done(err)
      )
