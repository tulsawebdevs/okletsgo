express         = require 'express'
http            = require 'http'
path            = require 'path'
coffeescript    = require('coffee-script')
io              = require('socket.io')
mongoose        = require 'mongoose'
Place           = require './models/place'

mongoose.connect process.env.OKLETSGO_MONGO

app = express()

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require('connect-assets')()

  app.use express.static path.join "#{__dirname}/public"

app.configure "development", () ->
  app.use express.errorHandler()
  return

app.get '/', (req, res) ->
  res.render('index', { title: 'Ok, lets go!' });
  return

app.get '/add', (req, res) ->
  res.render('add', { title: 'Ok, lets go!' });
  return

app.get '/places.json', (req, res) ->
  Place.findByLocation req.query, (err, places) ->
    if err
      res.json
        error: err
    else
      res.json places

app.post '/places.json', (req, res) ->
  place = Place.build req.body
  place.save (err) ->
    if err
      res.json
        error: err
    else
      res.json place

server = require('http').createServer(app)
server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
#io = io.listen(server)

#io.sockets.on "connection", (socket) ->
  #insert nail here, hammer is ready
