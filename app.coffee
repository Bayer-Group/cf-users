process.env.NODE_TLS_REJECT_UNAUTHORIZED= '0'
express = require 'express'
bodyParser = require 'body-parser'
jade = require 'jade'
path = require 'path'

routes = require './routes/index'
lessMiddleware = require 'less-middleware'
services = require "./routes/serviceBindings"
cfapiRouter = require('./routes/cfapiRouter')
contextRoot = 'cf-users'

fs = require 'fs'
normalizePort = (val) ->
  port = parseInt(val, 10);

  if isNaN port
    val
  else if port >= 0
    port
  else
    false

app = express()
#app.use (req,res,next)->
#  console.log("request",req)
#  next()
app.use bodyParser.urlencoded({ extended: true })
app.use bodyParser.json()
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

if process.env.NODE_ENV isnt 'production'
  webpackConfig = require './webpack.config'
  webpackConfig.output =
    path: '/'
    filename: "/#{contextRoot}/scripts/bundle.js"
  webpackConfig.devtool = '#eval'

  console.log 'running webpack dev middleware', webpackConfig

  app.use require('webpack-dev-middleware') require('webpack')(webpackConfig),
    stats: colors: true
    noInfo: true # Uncomment this for less verbose webpack information


app.use "/#{contextRoot}/styles", lessMiddleware __dirname + '/public/styles'
app.use "/#{contextRoot}/styles", express.static( __dirname + '/public/styles')
app.use "/#{contextRoot}/scripts", express.static( __dirname + '/public/scripts')
app.use "/#{contextRoot}/images", express.static( __dirname + '/public/images')
app.use "/#{contextRoot}/cf-api", cfapiRouter
app.use "/#{contextRoot}/roles", routes
app.use "/#{contextRoot}/adduser", routes
app.use "/#{contextRoot}/edituser", routes
app.use "/", (req,res,next)->
  res.redirect(301, "/#{contextRoot}/roles")
app.use "/#{contextRoot}/", (req,res,next)->
  res.redirect(301, "/#{contextRoot}/roles")

port = normalizePort process.env.VCAP_APP_PORT or process.env.PORT or '3000'
console.log("before createServer ######################################")
if process.env.NODE_ENV isnt 'production'
  https = require 'https'
  credentials =
    key : fs.readFileSync('./certs/localhost.key', 'utf8')
    cert : fs.readFileSync('./certs/localhost.cert', 'utf8')
  https.createServer(credentials, app).listen port
else
   http = require 'http'
   http.createServer( app).listen port
console.log("after createServer #######################################")