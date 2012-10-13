Mongoose = require('mongoose')

schema = Mongoose.Schema
  name:
    type: String
    require: true
  category:
    type: String
    required: true
  description: String
  tags: [String]
  address: String
  website: String
  start: Date
  end: Date
  location:
    type: [Number]
    require: true
    index: '2d'

schema.statics.findByLocation = (query, cb) ->
  if (query.lat? and query.lon?)
    q = @where('location', '$near': [query.lon, query.lat])
    q = q.where('category', query.category) if query.category
    q.exec cb
  else
    cb 'must supply lat and lon parameters'

module.exports = Mongoose.model 'Place', schema
