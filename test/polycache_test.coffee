"use strict"

{expect} = require "chai"
deferred = require "deferred"
uuid     = require "uuid"

PolyCache = require "../src/polycache"

sleep = (msec)->
  d = deferred()
  setTimeout(->
    d.resolve()
  , msec
  )
  d.promise

describe "PolyCache", ->
  describe "initialize Drivers", ->
    it "return memory driver", (done)->
      driver = new PolyCache.Memory()
      expect(driver).to.be.an.instanceof PolyCache.Memory

      driver.close()
      .then(->
        done()
      )
    it "return file driver", (done)->
      driver = new PolyCache.File()
      expect(driver).to.be.an.instanceof PolyCache.File

      driver.close()
      .then(->
        done()
      )
    it "return redis driver", (done)->
      driver = new PolyCache.Redis()
      expect(driver).to.be.an.instanceof PolyCache.Redis

      driver.close()
      .then(->
        done()
      )
    it "return memcached driver", (done)->
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
          conf =
            defaultDriver: PolyCache[driver]
          conf[driver.toLowerCase()] = setting

          cache = new PolyCache(conf)
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

  describe "no cache", ->
    it "enable noCache when config", ->
      cache = new PolyCache(noCache: true)
      expect(cache).to.have.property "noCache", true

    it "enable noCache when process", ->
      process.env.NO_CACHE=1
      cache = new PolyCache()
      expect(cache).to.have.property "noCache", true
      delete process.env.NO_CACHE

    it "return null if noCache get", (done)->
      [key, val] = ["mykey", "myval"]
      driver = new PolyCache(noCache: true)
      driver.set(key, val)
      .then(->
        driver.get(key)
      )
      .then((val)->
        expect(val).to.be.eql null
        done()
      )
      .finally(->
        driver.close()
      )

    it "return null if noCache getAndSet", (done)->
      [key, val] = ["mykey", "myval"]
      driver = new PolyCache(noCache: true)
      driver.set(key, val)
      .then(->
        driver.getAndSet(key, -> deferred("newval"))
      )
      .then((val)->
        expect(val).to.be.eql "newval"
        done()
      )
      .finally(->
        driver.close()
      )

  describe "redis expire", ->
    describe "set a and expire a", ->
      it "return null after expire", (done)->
        driver = new PolyCache.Redis()
        [key, val] = ["mykey", "myval"]
        driver.set(key, val, {expire: 1000})
        .then((v)->
          expect(v).to.be.eql val
          sleep(2000)
        )
        .then(->
          driver.get(key)
        )
        .then((v)->
          expect(v).to.be.eql null
          done()
        )
        .catch(done)

      it "return null after expireat", (done)->
        driver = new PolyCache.Redis()
        [key, val] = ["mykey", "myval"]
        driver.set(key, val, {expireat: Date.now() + 1000})
        .then((v)->
          expect(v).to.be.eql val
          sleep(2000)
        )
        .then(->
          driver.get(key)
        )
        .then((v)->
          expect(v).to.be.eql null
          done()
        )
        .catch(done)

    describe "getAndSet a and expire a", ->
      it "return null after expire", (done)->
        driver = new PolyCache(defaultDriver: PolyCache.Redis, redis: {})
        [key, val] = ["mykey#{uuid()}", "myval"]
        driver.getAndSet(key, (-> deferred(val)), {expire: 1000})
        .then((v)->
          expect(v).to.be.eql val
          sleep(2000)
        )
        .then(->
          driver.get(key)
        )
        .then((v)->
          expect(v).to.be.eql null
          done()
        )
        .catch(done)

      it "return null after expireat", (done)->
        driver = new PolyCache(defaultDriver: PolyCache.Redis, redis: {})
        [key, val] = ["mykey#{uuid()}", "myval"]
        driver.getAndSet(key, (-> deferred(val)), {expireat: Date.now() + 1000})
        .then((v)->
          expect(v).to.be.eql val
          sleep(2000)
        )
        .then(->
          driver.get(key)
        )
        .then((v)->
          expect(v).to.be.eql null
          done()
        )
        .catch(done)
