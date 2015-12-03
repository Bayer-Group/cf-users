gulp = require 'gulp'
coffee = require 'gulp-coffee'
less = require 'gulp-less'
env = require 'gulp-env'
sourcemaps = require 'gulp-sourcemaps'
supervisor = require 'gulp-supervisor'

gulp.task 'coffee', ->
  gulp.src './ui/**/*.coffee'
  .pipe sourcemaps.init()
  .pipe coffee bare: true
  .pipe sourcemaps.write()
  .pipe gulp.dest 'public/scripts/ui'

gulp.task 'less', ->
  gulp.src(['./styles/**/*.less', '!../styles/**/_*.less'])
  .pipe sourcemaps.init()
  .pipe less()
  .pipe sourcemaps.write()
  .pipe gulp.dest './public/styles/'


gulp.task 'set-env', ()->
  env
    vars :
      VCAP_SERVICES : """ {
            "user-provided" : [
             {
                "credentials" : {
            	  "portal-admin-id": "never",
                  "portal-admin-pw": "gonna",
                  "uaa-client-id": "give",
                  "uaa-client-secret": "you",
                  "uaa-domain": "up",
                  "login-domain" : "never",
                  "domain": "gonna",
                  "alias" : "cloud_foundry_api",
                  "default-email-domain" : "let@you.down"
                },
                "name" : "cloud_foundry_api_dev"
             }
            ]
       }
       """

gulp.task 'build', ['coffee', 'less']

gulp.task 'watch', ['build'], ->
  gulp.watch './styles/**/*.less', ['less']
  gulp.watch './ui/**/*.coffee', ['coffee']

gulp.task "supervise", ->
  supervisor "./bin/www",
    args: []
    watch: [ ".","views","routes" ]
    ignore: [ "ui", "public" ]
    pollInterval: 500
    extensions: [ "coffee","jade" ]
    exec: "node"
    debug: false
    debugBrk: false
    harmony: false
    noRestartOn: false
    forceWatch: false
    quiet: false

gulp.task 'default', ['set-env','build','watch','supervise']
