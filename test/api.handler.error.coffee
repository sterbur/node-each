
should = require 'should'
each = require '../src/each'

describe 'Error', ->
  
  it 'Concurrent # error and both callbacks', (next) ->
    current = 0
    error_called = false
    each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
    .parallel( 4 )
    .call (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 6 or element.id is 7
          next new Error "Testing error in #{element.id}"
        else
          next()
      , 100
    .error (err) ->
      current.should.eql 9
      err.message.should.eql 'Multiple errors (2)'
      err.errors.length.should.eql 2
      err.errors[0].message.should.eql 'Testing error in 6'
      err.errors[1].message.should.eql 'Testing error in 7'
      error_called = true
    .then ->
      error_called.should.be.true()
      arguments.length.should.eql 1
      arguments[0].should.be.a.Number()
      next()
      
  it 'Concurrent handle thrown error', (next) ->
    current = 0
    error_called = false
    each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
    .parallel( 4 )
    .call (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 6 or element.id is 7
        throw new Error "Testing error in #{element.id}"
      else 
        next()
    .error (err) ->
      current.should.eql 6
      err.message.should.eql 'Testing error in 6'
      err.should.not.have.property 'errors'
      error_called = true
    .then ->
      error_called.should.be.true()
      arguments.length.should.eql 1
      arguments[0].should.be.a.Number()
      next()
      
  it 'Parallel # multiple errors # error callback', (next) ->
    # when multiple errors are thrown, a new error object is created
    # with a message indicating the number of errors. The original 
    # errors are available as an array in the second argument of the
    # `error` event.
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .call (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 1 or element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .error (err) ->
      err.message.should.eql 'Multiple errors (2)'
      err.errors.length.should.eql 2
      err.errors[0].message.should.eql 'Testing error in 1'
      err.errors[1].message.should.eql 'Testing error in 3'
      next()
      
  it 'Parallel # single error # error callback', (next) ->
    # when on one error is thrown, the error is passed to
    # the `error` event as is as well as a single element array 
    # of the second argument.
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .call (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .error (err) ->
      err.message.should.eql 'Testing error in 3'
      next()
      
  it 'Parallel # async # both callback', (next) ->
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .call (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 1 or element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .error (err) ->
      err.message.should.eql 'Multiple errors (2)'
      err.errors.length.should.eql 2
      err.errors[0].message.should.eql 'Testing error in 1', 
      err.errors[1].message.should.eql 'Testing error in 3'
      next()
      
  it 'Parallel # sync # both callback', (next) ->
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .call (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 1 or element.id is 3
        next( new Error "Testing error in #{element.id}" )
      else setTimeout next, 100
    .error (err) ->
      # In this specific case, since the item handler
      # send error sequentially, we are only receiving
      # one error
      err.message.should.eql 'Testing error in 1'
      next()
      
  it 'Sequential # sync # error callback', (next) ->
    current = 0
    each( [ {id: 1}, {id: 2}, {id: 3} ] )
    .call (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 2
        next( new Error 'Testing error' )
      else next()
    .error (err) ->
      err.message.should.eql 'Testing error'
      next()
      
  it 'Sequential # async # error callback', (next) ->
    current = 0
    each( [ {id: 1}, {id: 2}, {id: 3} ] )
    .call (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 2
        setTimeout -> 
          next( new Error 'Testing error' )
        , 100
      else setTimeout next, 100
    .error (err) ->
      err.message.should.eql 'Testing error'
      next()
      
  it 'catch undefined', (next) ->
    each( [ 1, 2, 3 ] )
    .call (element, index, next) ->
      Toto.should.throw.an.error
    .error (err) ->
      err.message.should.eql 'Toto is not defined'
      next()
      
  it 'catch TypeError in concurrent mode', (next) ->
    each( [ 1, 2, 3 ] )
    .parallel( 4 )
    .call (element, index, next) ->
      undefined.should.throw.an.error
    .error (err) ->
      err.message.should.eql 'Cannot read property \'should\' of undefined'
      next()
      
  it 'rethrow if error inside error', (next) ->
    lsts = process.listeners 'uncaughtException'
    process.removeAllListeners 'uncaughtException'
    process.on 'uncaughtException', (err) ->
      err.message.should.eql 'User Error'
      process.removeAllListeners 'uncaughtException'
      for lst in lsts
        process.on 'uncaughtException', lst
      next()
    eacher = each()
    .times(10)
    .call (element, index, next) ->
      next()
    .error (err) ->
      throw Error 'User Error'
      
  it 'rethrow if error inside then', (next) ->
    lsts = process.listeners 'uncaughtException'
    process.removeAllListeners 'uncaughtException'
    process.on 'uncaughtException', (err) ->
      err.message.should.eql 'User Error'
      process.removeAllListeners 'uncaughtException'
      for lst in lsts
        process.on 'uncaughtException', lst
      next()
    eacher = each()
    .times(10)
    .call (element, index, next) ->
      next()
    .then (err) ->
      throw Error 'User Error'
  