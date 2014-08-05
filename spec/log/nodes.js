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
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    describe('first', function() {
      beforeEach(function() {
        return this.render([[0, 'foo\nbar'], [1, 'baz']]);
      });
      it('part', function() {
        return expect(this.log.children.first.id).toBe('0');
      });
      return it('span', function() {
        return expect(this.log.children.first.children.first.id).toBe('0-0');
      });
    });
    describe('last', function() {
      beforeEach(function() {
        return this.render([[0, 'foo\nbar'], [1, 'baz']]);
      });
      it('part', function() {
        return expect(this.log.children.last.id).toBe('1');
      });
      return it('span', function() {
        return expect(this.log.children.first.children.last.id).toBe('0-1');
      });
    });
    describe('prev', function() {
      beforeEach(function() {
        return this.render([[0, 'foo\nbar'], [1, 'baz']]);
      });
      it('part', function() {
        return expect(this.log.children.last.prev.id).toBe('0');
      });
      it('span', function() {
        return expect(this.log.children.first.children.last.prev.id).toBe('0-0');
      });
      return it('span with a removed sibling', function() {
        this.log.children.first.children.last.remove();
        return expect(this.log.children.last.children.first.prev.id).toBe('0-0');
      });
    });
    describe('next', function() {
      beforeEach(function() {
        return this.render([[0, 'foo\nbar'], [1, 'baz']]);
      });
      it('part', function() {
        return expect(this.log.children.first.next.id).toBe('1');
      });
      it('span', function() {
        return expect(this.log.children.first.children.first.next.id).toBe('0-1');
      });
      return it('span with a removed sibling', function() {
        this.log.children.first.children.last.remove();
        return expect(this.log.children.first.children.first.next.id).toBe('1-0');
      });
    });
    describe('isSequence', function() {
      beforeEach(function() {
        return this.render([[0, 'foo\nbar'], [1, 'baz'], [3, 'buz']]);
      });
      it('is true on the same part (left to right)', function() {
        return expect(this.log.children.first.children.first.isSequence(this.log.children.first.children.last)).toBe(true);
      });
      it('is true on the same part (right to left)', function() {
        return expect(this.log.children.first.children.last.isSequence(this.log.children.first.children.first)).toBe(true);
      });
      it('is true on an adjacent part (left to right)', function() {
        return expect(this.log.children.first.children.first.isSequence(this.log.children.first.next.children.last)).toBe(true);
      });
      it('is true on an adjacent part (right to left)', function() {
        return expect(this.log.children.first.next.children.last.isSequence(this.log.children.first.children.first)).toBe(true);
      });
      it('is false on a non-adjacent part (left to right)', function() {
        return expect(this.log.children.first.children.first.isSequence(this.log.children.last.children.last)).toBe(false);
      });
      return it('is false on a non-adjacent part (right to left)', function() {
        return expect(this.log.children.last.children.last.isSequence(this.log.children.first.children.first)).toBe(false);
      });
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
    describe('tail', function() {
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
      it('does not contain nodes that are children of a different dom node', function() {
        return rescueing(this, function() {
          var span;
          this.render([[0, 'foo\n'], [1, 'bar']]);
          span = this.log.children.first.children.first.children.first;
          return expect(span.tail.map(function(span) {
            return span.id;
          }).length).toBe(0);
        });
      });
      return it('does not contain nodes that are not immediate neighbors (parts)', function() {
        return rescueing(this, function() {
          var span;
          this.render([[1, '.'], [3, '.']]);
          span = this.log.children.first.children.first.children.first;
          return expect(span.tail.map(function(span) {
            return span.id;
          }).length).toBe(0);
        });
      });
    });
    it('removing a line fixes prev on the next lines', function() {
      return rescueing(this, function() {
        var ids, line, next, prev;
        line = (this.lines.items.filter(function(item) {
          return item.id === '0-1';
        }))[0];
        ids = [line.prev.id, line.next.id];
        prev = line.prev;
        next = line.next;
        line.remove();
        return expect([next.prev.id, prev.next.id]).toEqual(ids);
      });
    });
    return it('removing a span fixes prev on the next spans', function() {
      return rescueing(this, function() {
        var ids, next, prev, span;
        span = (this.lines.first.children.items.filter(function(item) {
          return item.id === '0-0-1';
        }))[0];
        ids = [span.prev.id, span.next.id];
        prev = span.prev;
        next = span.next;
        span.remove();
        return expect([next.prev.id, prev.next.id]).toEqual(ids);
      });
    });
  });

}).call(this);
