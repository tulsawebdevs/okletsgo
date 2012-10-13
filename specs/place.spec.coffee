Place = require('../models/place')

describe 'Place', ->
  describe '.findByLocation', ->
    it 'sets where on location with maxDistance of 10 miles by default', ->
      spyOn(Place, 'where').andReturn(Place)
      Place.exec = ->
      Place.findByLocation
        lat: 1
        lon: 2
      calls = Place.where.argsForCall
      args = calls[0]
      expect(calls.length).toEqual(1)
      expect(args[0]).toEqual('location')
      expect(args[1]['$near']).toEqual [2, 1]
      expect(args[1]['$maxDistance']).toBeCloseTo(0.14, 0.01)

    it 'sets maxDistance of 20 miles when specified', ->
      spyOn(Place, 'where').andReturn(Place)
      Place.exec = ->
      Place.findByLocation
        lat: 1
        lon: 2
        distance: 20
      args = Place.where.argsForCall[0]
      expect(args[1]['$maxDistance']).toBeCloseTo(0.29, 0.01)

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

    it 'should also return distance as well', ->
      cb = jasmine.createSpy("callback")
      spyOn(Place, 'where').andReturn(Place)
      Place.exec = jasmine.createSpy('exec')
      Place.findByLocation({lat: 1, lon: 2}, cb)
      dcb = Place.exec.mostRecentCall.args[0]
      dcb null, [
        new Place 
          location: [2, 1]
      ]
      data = cb.mostRecentCall.args[1]
      expect(data[0].toJSON().distance).toEqual(0)

  describe '.milesToDegrees', ->
    it 'should return about 1 degree, given 69 miles', ->
      deg = Place.milesToDegrees 69
      expect(deg).toBeCloseTo(1, 0.01)

    it 'should return about 1.44 degrees, given 100 miles', ->
      deg = Place.milesToDegrees 100
      expect(deg).toBeCloseTo(1.44, 0.01)

    it 'should return about 1.44 degrees, given 200 miles (max 100)', ->
      deg = Place.milesToDegrees 200
      expect(deg).toBeCloseTo(1.44, 0.01)

  describe '#getDistance', ->
    it 'should return distance in miles from the specified origin to the place location', ->
      place = new Place
        location: [-95.9925, 36.1539]
      distance = place.getDistance -97.5352, 35.4823
      expect(distance).toBeCloseTo(98.1, 0.1)
