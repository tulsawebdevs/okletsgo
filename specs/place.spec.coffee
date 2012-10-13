Place = require('../models/place')

describe 'Place', ->
  describe '.findByLocation', ->

    cb = null

    beforeEach ->
      spyOn(Place, 'where').andReturn(Place)
      cb = jasmine.createSpy("callback")
      Place.exec = jasmine.createSpy('exec')

    describe 'given parameters lat and lon', ->
      calls = null

      beforeEach ->
        Place.findByLocation
          lat: 1
          lon: 2
        calls = Place.where.argsForCall

      it 'filters $near lat, lon with maxDistance of 10 miles by default', ->
        args = calls[0]
        expect(args[0]).toEqual('location')
        expect(args[1]['$near']).toEqual [2, 1]
        expect(args[1]['$maxDistance']).toBeCloseTo(0.14, 0.01)

      it 'does not filter on category', ->
        expect(calls.length).toEqual(2)

      it 'returns distance for each place', ->
        Place.findByLocation({lat: 1, lon: 2}, cb)
        mongoose_cb = Place.exec.mostRecentCall.args[0]
        mongoose_cb null, [
          new Place
            location: [3, 2]
        ]
        data = cb.mostRecentCall.args[1]
        expect(data[0].toJSON().distance).toBeCloseTo(97.8, 0.1)

      it 'queries only published places', ->
        args = calls[1]
        expect(args).toEqual ['published', true]

    describe 'given parameters lat, lon, and distance', ->
      beforeEach ->
        Place.findByLocation
          lat: 1
          lon: 2
          distance: 20

      it 'filters $near lat, lon with given maxDistance', ->
        args = Place.where.argsForCall[0]
        expect(args[1]['$maxDistance']).toBeCloseTo(0.29, 0.01)

    describe 'given missing parameters lat and lon', ->
      beforeEach ->
        Place.findByLocation {}, cb

      it 'returns an error if missing lat lon', ->
        expect(cb).toHaveBeenCalledWith 'must supply lat and lon parameters'

    describe 'given parameters lat, lon, and category', ->
      beforeEach ->
        Place.findByLocation
          lat: 1
          lon: 2
          category: 'museum'

      it 'sets where on location and given category', ->
        expect(Place.where).toHaveBeenCalledWith 'category', 'museum'

  describe '.milesToDegrees', ->
    it 'returns about 1 degree, given 69 miles', ->
      deg = Place.milesToDegrees 69
      expect(deg).toBeCloseTo(1, 0.01)

    it 'returns about 1.44 degrees, given 100 miles', ->
      deg = Place.milesToDegrees 100
      expect(deg).toBeCloseTo(1.44, 0.01)

    it 'returns about 1.44 degrees, given 200 miles (max 100)', ->
      deg = Place.milesToDegrees 200
      expect(deg).toBeCloseTo(1.44, 0.01)

  describe '#getDistance', ->
    it 'returns distance in miles from the specified origin to the place location', ->
      place = new Place
        location: [-95.9925, 36.1539]
      distance = place.getDistance -97.5352, 35.4823
      expect(distance).toBeCloseTo(98.1, 0.1)
