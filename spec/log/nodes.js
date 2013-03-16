(function() {

  describe('Nodes', function() {
    var head, tail;
    head = function(node) {
      var ids;
      ids = [];
      while (node = node.prev) {
        ids.unshift(node);
      }
      return ids;
    };
    tail = function(node) {
      var ids;
      ids = [];
      while (node = node.next) {
        ids.push(node);
      }
      return ids;
    };
    return beforeEach(function() {
      return rescueing(this, function() {
        var id, ids, ix, line, spans, _i, _len, _ref, _results;
        this.log = new Log.Part('0');
        this.lines = this.log.children;
        ids = [['1-1', ['1-1-0', '1-1-2', '1-1-1']], ['0-1', ['0-1-1', '0-1-0', '0-1-2']], ['0-0', ['0-0-2', '0-0-0', '0-0-1']], ['1-0', ['1-0-2', '1-0-0', '1-0-1']]];
        _results = [];
        for (_i = 0, _len = ids.length; _i < _len; _i++) {
          _ref = ids[_i], id = _ref[0], spans = _ref[1];
          line = this.log.addChild(new Log.Line(id));
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (ix = _j = 0, _len1 = spans.length; _j < _len1; ix = ++_j) {
              id = spans[ix];
              _results1.push(line.addChild(new Log.Span(id, ix, {
                text: ''
              })));
            }
            return _results1;
          })());
        }
        return _results;
      });
    });
  });

}).call(this);
