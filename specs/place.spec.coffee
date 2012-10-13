_ = require('underscore')
Place = require('../models/place')

describe 'Place', ->
  describe '.findByLocation', ->

    query = null
    cb = null

    beforeEach ->
      query = {where: null, skip: null, limit: null, exec: ->}
      spyOn(query, 'where').andReturn(query)
      spyOn(query, 'skip').andReturn(query)
      spyOn(query, 'limit').andReturn(query)
      spyOn(query, 'exec')
      spyOn(Place, 'find').andReturn(query)
      cb = jasmine.createSpy("callback")

    describe 'given parameters lat and lon', ->
      where = null
      skip = null
      limit = null

      beforeEach ->
        Place.findByLocation
          lat: 1
          lon: 2
        where = query.where.argsForCall

      it 'filters $near lat, lon with maxDistance of 10 miles by default', ->
        args = where[0]
        expect(args[0]).toEqual('location')
        expect(args[1]['$near']).toEqual [2, 1]
        expect(args[1]['$maxDistance']).toBeCloseTo(0.14, 0.01)

      it 'does not filter on category', ->
        expect(where.length).toEqual(2)

      it 'returns distance for each place', ->
        Place.findByLocation({lat: 1, lon: 2}, cb)
        mongoose_cb = query.exec.mostRecentCall.args[0]
        mongoose_cb null, [
          new Place
            location: [3, 2]
        ]
        data = cb.mostRecentCall.args[1]
        expect(data[0].toJSON().distance).toBeCloseTo(97.8, 0.1)

      it 'queries only published places', ->
        args = where[1]
        expect(args).toEqual ['published', true]

    describe 'given parameters lat, lon, and distance', ->
      beforeEach ->
        Place.findByLocation
          lat: 1
          lon: 2
          distance: 20

      it 'filters $near lat, lon with given maxDistance', ->
        args = query.where.argsForCall[0]
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

      it 'filters $near lat, lon and given category', ->
        expect(query.where).toHaveBeenCalledWith 'category', 'museum'

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

  describe 'new Place', ->
    describe 'given name, category, and location', ->
      place = null

      beforeEach ->
        place = new Place
          name: 'Foo'
          category: 'hotel'
          location: [2, 1]

      it 'sets published to false', ->
        expect(place.published).toEqual(false)

    describe 'given no attributes', ->
      place = null
      cb = null
      result = null

      beforeEach ->
        place = new Place
        runs -> place.validate (err) -> result = err
        waitsFor (-> result), 'callback not called', 100

      it 'fails validation for name attribute', ->
        runs -> expect(_.pluck(result.errors, 'path')).toContain 'name'

      it 'fails validation for location attribute', ->
        runs -> expect(_.pluck(result.errors, 'path')).toContain 'location'

      it 'fails validation for category attribute', ->
        runs -> expect(_.pluck(result.errors, 'path')).toContain 'category'
