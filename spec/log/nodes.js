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
    return describe('isSequence', function() {
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
  });

}).call(this);
