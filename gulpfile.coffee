"use strict"

path            = require "path"

gulp            = require "gulp"
coffee          = require "gulp-coffee"
plumber         = require "gulp-plumber"
util            = require "gulp-util"
mocha           = require "gulp-mocha"

# each task
gulp.task "coffee", ->
  gulp.src("./src/**/*.coffee")
  .pipe(plumber())
  .pipe(coffee({bare: true})).on("error", util.log)
  .pipe(gulp.dest("./lib"))


# watch task
gulp.task "watch", ->
  gulp.watch("./src/**/*.coffee", [ "coffee" ])

# test
gulp.task "test" , ->
  gulp.src("test/**/*_test.coffee")
    .pipe(plumber())
    .pipe(mocha {reporter: "spec"}).on("error", util.log)

# default
gulp.task "build", [ "coffee" ]

gulp.task "default", ["build", "test"]
