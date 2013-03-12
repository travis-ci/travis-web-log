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
    beforeEach(function() {
      return rescueing(this, function() {
        var id, ids, line, spans, _i, _len, _ref, _results;
        this.log = new Log.Part;
        this.lines = this.log.children;
        ids = [['1-1', ['1-1-0', '1-1-2', '1-1-1']], ['0-1', ['0-1-1', '0-1-0', '0-1-2']], ['0-0', ['0-0-2', '0-0-0', '0-0-1']], ['1-0', ['1-0-2', '1-0-0', '1-0-1']]];
        _results = [];
        for (_i = 0, _len = ids.length; _i < _len; _i++) {
          _ref = ids[_i], id = _ref[0], spans = _ref[1];
          line = this.lines.add(new Log.Line(id));
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = spans.length; _j < _len1; _j++) {
              id = spans[_j];
              _results1.push(line.addChild(new Log.Span(id, {
                text: ''
              })));
            }
            return _results1;
          })());
        }
        return _results;
      });
    });
    it('inserting lines', function() {
      return expect(this.lines.map(function(node) {
        return node.id;
      })).toEqual(['0-0', '0-1', '1-0', '1-1']);
    });
    it('inserting spans', function() {
      return expect(this.lines.first.children.map(function(node) {
        return node.id;
      })).toEqual(['0-0-0', '0-0-1', '0-0-2']);
    });
    it('first', function() {
      return expect(this.lines.first.id).toBe('0-0');
    });
    it('last', function() {
      return expect(this.lines.last.id).toBe('1-1');
    });
    it('sets next on lines', function() {
      var ids;
      ids = head(this.lines.last).map(function(node) {
        return node.id;
      });
      return expect(ids).toEqual(['0-0', '0-1', '1-0']);
    });
    it('sets prev on lines', function() {
      var ids;
      ids = tail(this.lines.first).map(function(node) {
        return node.id;
      });
      return expect(ids).toEqual(['0-1', '1-0', '1-1']);
    });
    it('sets prev (nested)', function() {
      var ids;
      ids = head(this.lines.last.children.last).map(function(node) {
        return node.id;
      });
      return expect(ids).toEqual(['0-0-0', '0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1']);
    });
    return it('sets next (nested)', function() {
      var ids;
      ids = tail(this.lines.first.children.first).map(function(node) {
        return node.id;
      });
      return expect(ids).toEqual(['0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1', '1-1-2']);
    });
  });

}).call(this);
