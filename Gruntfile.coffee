module.exports = (grunt)->
  "use strict"

  pkg = require "./package.json"

  grunt.initConfig
    coffee:
      options:
        bare: true
      src:
        files:
          "lib/polycache.js":      "src/polycache.coffee"
    simplemocha:
      all:
        src: [
          "test/**_test.coffee"
        ]
      options:
        ui: "bdd"
        reporter: "spec"
    blanket_mocha:
      test:
        src: [ "test/**_test.coffee" ]


  for name of pkg.devDependencies when name.indexOf("grunt-") is 0 and name isnt "grunt-cli"
    grunt.loadNpmTasks name

  grunt.registerTask "test", [ "simplemocha" ]
  grunt.registerTask "default", [ "coffee" ]
