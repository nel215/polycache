"use strict"

deferred        = require "deferred"
fs              = require "fs"
Path            = require "path"
mkdirp          = require "mkdirp"
crypto          = require "crypto"
msgpack         = require "msgpack"

module.exports = class File
  constructor: (config = {})->
    @filedir = Path.join config.dir or "./tmp"

    mkdirp.sync(@filedir)

  toKey: (path)->
    crypto.createHash("sha1").update(path, "ascii").digest("hex")

  get: (key)->
    d = deferred()
    fs.readFile(
      Path.join(@filedir, @toKey(key)),
      (err, data)->
        d.resolve if data? then msgpack.unpack(data) else undefined
    )
    d.promise

  set: (key, val)->
    d = deferred()
    fs.writeFile(
      Path.join(@filedir, @toKey(key)),
      msgpack.pack(val),
      (err)->
        return d.reject err if err
        d.resolve val
    )
    d.promise

  del: (key)->
    d = deferred()
    fs.unlink(Path.join(@filedir, @toKey(key)), (err)->
      return d.reject err if err
      d.resolve true
    )
    d.promise

  # TODO: the key files are all in filedir so not recurrsive
  close: ()->
    @removeFileRec(@filedir)

  removeFileRec: (path)->
    d = deferred()

    files = fs.readdir(path, (err, files)->
      files.filter((f)-> not f.match(/^\.+$/)).forEach (file)->
        fs.unlinkSync(Path.join(path, file))

      fs.rmdir(path, (err)->
        d.resolve()
      )
    )

    d.promise
