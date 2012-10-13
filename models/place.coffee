MAX_DISTANCE_IN_MILES = 100
DEFAULT_DISTANCE_IN_MILES = 10

Mongoose = require('mongoose')

schema = Mongoose.Schema
  name:
    type: String
    required: true
  category:
    type: String
    required: true
  description: String
  tags: [String]
  address: String
  website: String
  start: Date
  end: Date
  image_credit: String
  location:
    type: [Number]
    required: true
    index: '2d'
  distance: Number # FIXME this should be a virtual attribute
  published:
    type: Boolean
    default: false

schema.methods.getDistance = (lon, lat) ->
  R = 3961 # miles

  lat1 = @location[1]
  lon1 = @location[0]
  lat2 = lat
  lon2 = lon

  dLat = (lat2-lat1) * Math.PI / 180
  dLon = (lon2-lon1) * Math.PI / 180
  lat1 = lat1 * Math.PI / 180
  lat2 = lat2 * Math.PI / 180

  a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)  

  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))  
  R * c

schema.statics.findByLocation = (query, cb) ->
  if (query.lat? and query.lon?)
    q = @where 'location',
      '$near': [query.lon, query.lat]
      '$maxDistance': @milesToDegrees(query.distance || DEFAULT_DISTANCE_IN_MILES)
    q = q.where('published', true)
    q = q.where('category', query.category) if query.category
    q.exec (err, places) ->
      for place in places
        place.distance = place.getDistance(query.lon, query.lat)
      cb(err, places)
  else
    cb 'must supply lat and lon parameters'

schema.statics.milesToDegrees = (miles) ->
  Math.min(miles, MAX_DISTANCE_IN_MILES) / 69

module.exports = Mongoose.model 'Place', schema
