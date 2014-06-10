"use strict"

{expect} = require "chai"
deferred = require "deferred"

PolyCache = require "../src/polycache"

describe "PolyCache", ->
  describe "Drivers", ->
    it "memory driver", (done)->
      driver = new PolyCache.Memory()
      expect(driver).to.be.an.instanceof PolyCache.Memory

      driver.close()
      .then(->
        done()
      )
    it "file driver", (done)->
      driver = new PolyCache.File()
      expect(driver).to.be.an.instanceof PolyCache.File

      driver.close()
      .then(->
        done()
      )
    it "redis driver", (done)->
      driver = new PolyCache.Redis()
      expect(driver).to.be.an.instanceof PolyCache.Redis

      driver.close()
      .then(->
        done()
      )
    it "memcached driver", (done)->
      driver = new PolyCache.Memcached()
      expect(driver).be.an.instanceof PolyCache.Memcached

      driver.close()
      .then(->
        done()
      )

  driverSetting =
    Memory:     {}
    File:       dir: "./tmp"
    Redis:
      host: "localhost"
      port: 6379

  for driver, setting of driverSetting
    do (driver, setting)->
      describe driver, ->
        cache = null
        beforeEach (done)->
          cache = new PolyCache(
            defaultDriver: PolyCache[driver](setting)
          )
          done()

        afterEach (done)->
          cache.close()
          .then(->
            done()
          )

        it "set and get object", (done)->
          key = "#{driver}-object"
          val = {name: "muddydixon", age: 35}
          cache.set(key, val)
          .then(->
            cache.get(key)
          )
          .then((val)->
            expect(val).to.be.eql val
            done()
          )
          .catch((err)->
            done(err)
          )

        it "set and get Array", (done)->
          key = "#{driver}-object"
          val = [10, 20, "name"]
          cache.set(key, val)
          .then(->
            cache.get(key)
          )
          .then((val)->
            expect(val).to.be.eql val
            done()
          )
          .catch((err)->
            done(err)
          )

        it "set and get number as string", (done)->
          key = "#{driver}-number-string"
          val = "10"
          cache.set(key, val)
          .then(->
            cache.get(key)
          )
          .then((val)->
            expect(val).to.be.eql val
            done()
          )
          .catch((err)->
            done(err)
          )

        it "set and get double number", (done)->
          key = "#{driver}-number-string"
          val = 0.0005
          cache.set(key, val)
          .then(->
            cache.get(key)
          )
          .then((val)->
            expect(val).to.be.eql val
            done()
          )
          .catch((err)->
            done(err)
          )

        it "set and get number", (done)->
          key = "#{driver}-number"
          val = 10
          cache.set(key, 10)
          .then(->
            cache.get(key)
          )
          .then((val)->
            expect(val).to.be.eql 10
            done()
          )
          .catch((err)->
            done(err)
          )

        it "getAndSet key, call", (done)->
          key = "#{driver}-getAndSet"
          val = 10
          cache.getAndSet(key, ()-> deferred(val))
          .then((val)->
            expect(val).to.be.eql val
          )
          .then(->
            cache.getAndSet(key, ()->
              done(new Error("this should not be called"))
              deferred(20)
            )
          )
          .then((val)->
            expect(val).to.be.eql val
          )
          .then(->
            cache.del(key)
          )
          .then(->
            done()
          )
          .catch((err)->
            done(err)
          )
