// Generated by CoffeeScript 1.4.0
(function() {
  var partition, randomize, shuffle, urls;

  urls = ['http://localhost:9292/jobs/4754461/log.txt', 'https://s3.amazonaws.com/archive.travis-ci.org/jobs/4693454/log.txt', 'https://api.travis-ci.org/jobs/4754461/log.txt'];

  shuffle = function(array, start, count) {
    var i, j, tmp, _, _i, _len, _ref, _results;
    _ref = array.slice(start, start + count);
    _results = [];
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      _ = _ref[i];
      j = start + Math.floor(Math.random() * (i + 1));
      i = start + i;
      tmp = array[i];
      array[i] = array[j];
      _results.push(array[j] = tmp);
    }
    return _results;
  };

  randomize = function(array, step) {
    var i, _, _i, _len, _step;
    for (i = _i = 0, _len = array.length, _step = step; _i < _len; i = _i += _step) {
      _ = array[i];
      shuffle(array, i, step);
    }
    return array;
  };

  partition = function(string) {
    var i, line, lines, parts;
    lines = string.split(/^/m);
    parts = (function() {
      var _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = lines.length; _i < _len; i = ++_i) {
        line = lines[i];
        _results.push([i, line]);
      }
      return _results;
    })();
    parts = randomize(parts);
    return parts;
  };

  $(function() {
    var log;
    log = new Log;
    log.listeners.push(new Log.Renderer);
    return $.get(urls[2], function(string) {
      var part, parts, set, wait, _i, _len, _results;
      parts = partition(string);
      parts = parts.slice(0, 30);
      wait = 0;
      set = function(ix, line) {
        return log.set(ix, line);
      };
      _results = [];
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        _results.push(setTimeout(set, wait += 10, part[0], part[1]));
      }
      return _results;
    });
  });

}).call(this);
