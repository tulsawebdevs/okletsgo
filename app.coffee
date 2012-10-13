express = require 'express'
http = require 'http'
path = require 'path'
mongoose = require 'mongoose'
Place = require './models/place'

mongoose.connect 'localhost/okletsgo'

app = express()

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static path.join "#{__dirname}/public"

app.configure "development", () ->
  app.use express.errorHandler()
  return

app.get '/', (req, res) ->
  res.render('index', { title: 'Express' });
  return

app.get '/places.json', (req, res) ->
  Place.findByLocation req.query, (err, places) ->
    if err
      res.json 
        error: err
    else
      res.json places

http.createServer(app).listen app.get('port'), () ->
  console.log "listening on port 3000"
  return
