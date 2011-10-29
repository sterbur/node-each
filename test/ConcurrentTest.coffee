
assert = require 'assert'
each = require '../index'

module.exports = 
    'Concurrent # array # multiple elements # async callbacks # no end callback': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ]
        each source, 4, (element, n) ->
            unless n
                assert.eql current, 9
                return setTimeout next, 100
            current++
            assert.eql current, element.id
            setTimeout n, 100
    'Concurrent # array # error # async callbacks # no end callback': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ]
        each source, 4, (element, n) ->
            if n instanceof Error
                assert.eql 8, current
                assert.eql '2 error(s)', n.message
                assert.eql 2, n.errors.length
                assert.eql 'Testing error in 6', n.errors[0].message
                assert.eql 'Testing error in 7', n.errors[1].message
                return next()
            current++
            if element.id is 6 or element.id is 7
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
    'Concurrent # array # multiple elements # async callbacks # end callback': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ]
        each source, 4, (element, n) ->
            current++
            assert.eql current, element.id
            setTimeout n, 100
        , (err) ->
            assert.eql current, 9
            return setTimeout next, 100
    'Concurrent # array # one element # async callbacks': (next) ->
        current = 0
        source = [ {id: 1} ]
        each source, 4, (element, n) ->
            unless n
                assert.eql current, 1
                return setTimeout next, 100
            current++
            assert.eql current, element.id
            setTimeout n, 100
    'Concurrent # array sync callback': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ]
        each source, 4, (element, n) ->
            unless n
                assert.eql current, 9
                return next()
            current++
            assert.eql current, element.id
            n()
    'Concurrent # object async callbacks': (next) ->
        current = 0
        source = id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9
        each source, 4, (key, value, n) ->
            unless n
                assert.eql current, 9
                return setTimeout next, 100
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
    'Concurrent # object sync callbacks': (next) ->
        current = 0
        source = id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9
        each source, 4, (key, value, n) ->
            unless n
                assert.eql current, 9
                return next()
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            n()