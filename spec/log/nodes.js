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
    it('sets part on lines', function() {
      return expect(this.lines.last.part.id).toBe('0');
    });
    it('sets part on spans', function() {
      return expect(this.lines.last.children.last.part.id).toBe('0');
    });
    describe('head', function() {
      beforeEach(function() {
        while (log.firstChild) {
          log.removeChild(log.firstChild);
        }
        this.log = new Log;
        return this.render = function(parts) {
          return render(this, parts);
        };
      });
      it('contains nodes that are both dom siblings and immediate neighbors', function() {
        return rescueing(this, function() {
          var span;
          this.render([[1, '.'], [2, '.'], [3, '.']]);
          span = this.log.children.last.children.last.children.last;
          return expect(span.head.map(function(span) {
            return span.id;
          }).join(', ')).toBe('1-0-0, 2-0-0');
        });
      });
      it('does not contain nodes that are children of a different dom node', function() {
        return rescueing(this, function() {
          var span;
          this.render([[0, 'foo\n'], [1, 'bar']]);
          span = this.log.children.last.children.last.children.last;
          return expect(span.head.map(function(span) {
            return span.id;
          }).length).toBe(0);
        });
      });
      return it('does not contain nodes that are not immediate neighbors (parts)', function() {
        return rescueing(this, function() {
          var span;
          this.render([[1, '.'], [3, '.']]);
          span = this.log.children.last.children.last.children.last;
          return expect(span.head.map(function(span) {
            return span.id;
          }).length).toBe(0);
        });
      });
    });
    return describe('tail', function() {
      beforeEach(function() {
        while (log.firstChild) {
          log.removeChild(log.firstChild);
        }
        this.log = new Log;
        return this.render = function(parts) {
          return render(this, parts);
        };
      });
      it('contains nodes that are both dom siblings', function() {
        return rescueing(this, function() {
          var span;
          this.render([[1, '.'], [2, '.'], [3, '.']]);
          span = this.log.children.first.children.first.children.first;
          return expect(span.tail.map(function(span) {
            return span.id;
          }).join(', ')).toBe('2-0-0, 3-0-0');
        });
      });
      return it('does not contain nodes that are children of a different dom node', function() {
        return rescueing(this, function() {
          var span;
          this.render([[0, 'foo\n'], [1, 'bar']]);
          span = this.log.children.first.children.first.children.first;
          return expect(span.tail.map(function(span) {
            return span.id;
          }).length).toBe(0);
        });
      });
    });
  });

}).call(this);
