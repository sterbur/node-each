// Generated by CoffeeScript 1.4.0
var Stream;

Stream = require('stream');

/*
each(elements)
.mode(parallel=false|true|integer)
.on('item', callback)
.on('error', callback)
.on('end', callback)
.on('both', callback)
Chained and parallel async iterator in one elegant function
*/


module.exports = function(elements) {
  var eacher, errors, events, isObject, keys, next, parallel, run, type;
  type = typeof elements;
  if (elements === null || type === 'undefined' || type === 'number' || type === 'string' || type === 'function' || type === 'boolean') {
    elements = [elements];
  } else if (!Array.isArray(elements)) {
    isObject = true;
  }
  if (isObject) {
    keys = Object.keys(elements);
  }
  errors = [];
  parallel = 1;
  events = {
    item: [],
    error: [],
    end: [],
    both: []
  };
  eacher = {};
  eacher.total = keys ? keys.length : elements.length;
  eacher.started = 0;
  eacher.done = 0;
  eacher.paused = 0;
  eacher.readable = true;
  eacher.pause = function() {
    return eacher.paused++;
  };
  eacher.resume = function() {
    eacher.paused--;
    return run();
  };
  eacher.parallel = function(mode) {
    if (typeof mode === 'number') {
      parallel = mode;
    } else if (mode) {
      parallel = eacher.total;
    } else {
      parallel = 1;
    }
    return eacher;
  };
  eacher.on = function(ev, callback) {
    events[ev].push(callback);
    return eacher;
  };
  run = function() {
    var args, e, emitError, lboth, lerror, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;
    if (eacher.paused) {
      return;
    }
    if (eacher.done === eacher.total || (errors.length && eacher.started === eacher.done)) {
      eacher.readable = false;
      if (errors.length) {
        if (parallel !== 1) {
          if (errors.length === 1) {
            args = [errors[0], errors];
          } else {
            args = [new Error("Multiple errors (" + errors.length + ")"), errors];
          }
        } else {
          args = [errors[0]];
        }
        lerror = events.error.length;
        lboth = events.both.length;
        emitError = lerror || (!lerror && !lboth);
        _ref = events.error;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          if (emitError) {
            e.apply(null, args);
          }
        }
      } else {
        args = [];
        _ref1 = events.end;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          e = _ref1[_j];
          e();
        }
      }
      _ref2 = events.both;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        e = _ref2[_k];
        e.apply(null, args);
      }
      return;
    }
    if (errors.length !== 0) {
      return;
    }
    _results = [];
    while (Math.min(parallel - eacher.started + eacher.done, eacher.total - eacher.started)) {
      if (errors.length !== 0) {
        break;
      }
      if (keys) {
        args = [next, keys[eacher.started], elements[keys[eacher.started]]];
      } else {
        args = [next, elements[eacher.started], eacher.started];
      }
      eacher.started++;
      try {
        _results.push((function() {
          var _l, _len3, _ref3, _results1;
          _ref3 = events.item;
          _results1 = [];
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            e = _ref3[_l];
            _results1.push(e.apply(null, args));
          }
          return _results1;
        })());
      } catch (e) {
        if (eacher.readable) {
          _results.push(next(e));
        } else {
          _results.push(void 0);
        }
      }
    }
    return _results;
  };
  next = function(err) {
    if ((err != null) && err instanceof Error) {
      errors.push(err);
    }
    eacher.done++;
    return run();
  };
  process.nextTick(run);
  return eacher;
};