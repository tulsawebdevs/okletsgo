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

  describe '#getDistance', ->
    it 'should return distance between 2 points', ->
      place = new Place
        location: [-95.9925, 36.1539]

      distance = place.getDistance 35.4823, -97.5352
      expect(distance).toBeCloseTo(157.8, 0.1)
