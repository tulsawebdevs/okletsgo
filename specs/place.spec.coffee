Place = require('../models/place')

describe 'Place', ->
  describe '.findByLocation', ->
    it 'sets where on location', ->
      spyOn(Place, 'where').andReturn(Place)
      Place.exec = ->
      Place.findByLocation
        lat: 1
        lon: 2
      expect(Place.where).toHaveBeenCalledWith 'location',
        '$near': [2, 1]
      console.log Place.where.argsForCall
      expect(Place.where.argsForCall.length).toEqual(1)

    it 'does not search if missing lat lon', ->
      cb = jasmine.createSpy("callback")
      Place.findByLocation({}, cb)
      expect(cb).toHaveBeenCalledWith 'must supply lat and lon parameters'

    it 'sets where on location and category', ->
      spyOn(Place, 'where').andReturn(Place)
      Place.exec = ->
      Place.findByLocation
        lat: 1
        lon: 2
        category: 'museum'
      expect(Place.where).toHaveBeenCalledWith 'category', 'museum'
