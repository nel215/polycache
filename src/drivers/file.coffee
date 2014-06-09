"use strict"

deferred        = require "deferred"
fs              = require "fs"
Path            = require "path"
uuid            = require "uuid"
mkdirp          = require "mkdirp"
crypto          = require "crypto"

module.exports = class File
  constructor: (config = {})->
    @id = uuid()
    @filedir = Path.join config.dir or "./tmp", @id

    mkdirp.sync(@filedir)

  toKey: (path)->
    crypto.createHash("sha1").update(path, "ascii").digest("hex")

  get: (key)->
    d = deferred()
    fs.readFile(Path.join(@filedir, @toKey(key)), "utf8", (err, data)->
      d.resolve if data? then data else undefined
    )
    d.promise

  set: (key, val)->
    d = deferred()
    _val = val
    if typeof val isnt 'string'
      _val = JSON.stringify val

    fs.writeFile(Path.join(@filedir, @toKey(key)), _val, {encoding: "utf8"}, (err)->
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
  end: ()->
    @removeFileRec(@filedir)

  removeFileRec: (path)->
    d = deferred()

    files = fs.readdir(path, (err, files)->
      files.filter((f)-> not f.match(/^\.+$/)).forEach (file)->
        console.log file
        fs.unlinkSync(Path.join(path, file))

      fs.rmdir(path, (err)->
        d.resolve()
      )
    )

    d.promise
