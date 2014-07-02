module.exports = (grunt) ->
  "use strict"

  # packages
  # --------------------------------------------------
  pkg = require "./package.json"


  # configuration
  # --------------------------------------------------
  grunt.initConfig
    coffee:
      options:
        bare: true
      all:
        files:
          "lib/polycache.js":           "src/polycache.coffee"
          "lib/drivers/memory.js":      "src/drivers/memory.coffee"
          "lib/drivers/file.js":        "src/drivers/file.coffee"
          "lib/drivers/memcached.js":   "src/drivers/memcached.coffee"
          "lib/drivers/redis.js":       "src/drivers/redis.coffee"

    simplemocha:
      all:
        src: [
          "test/*_test.coffee"
        ]
      options:
        ui: "bdd"
        reporter: "spec"


  for name of pkg.devDependencies when name.substring(0, 6) is "grunt-" and name isnt "grunt-cli"
    grunt.loadNpmTasks name

  grunt.registerTask "test", [ "simplemocha" ]
  grunt.registerTask "default", [ "test", "coffee"  ]
