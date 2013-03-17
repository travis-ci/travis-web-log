(function() {

  describe('Log.Limit', function() {
    var format, rescueing, strip;
    strip = function(string) {
      return string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '');
    };
    format = function(html) {
      return html.replace(/<div/gm, '\n<div').replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span');
    };
    rescueing = function(context, block) {
      var line, _i, _len, _ref, _results;
      try {
        return block.apply(context);
      } catch (e) {
        _ref = e.stack.split("\n");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          _results.push(console.log(line));
        }
        return _results;
      }
    };
    beforeEach(function() {
      return rescueing(this, function() {
        while (log.firstChild) {
          log.removeChild(log.firstChild);
        }
        this.log = Log.create({
          engine: Log.Dom,
          limit: 2
        });
        return this.render = function(data) {
          return rescueing(this, function() {
            var num, string, _i, _len, _ref;
            for (_i = 0, _len = data.length; _i < _len; _i++) {
              _ref = data[_i], num = _ref[0], string = _ref[1];
              this.log.set(num, string);
            }
            return strip(document.firstChild.innerHTML);
          });
        };
      });
    });
    it('counts the lines', function() {
      var num;
      this.render((function() {
        var _i, _results;
        _results = [];
        for (num = _i = 1; _i <= 2; num = ++_i) {
          _results.push([num, 'foo\n']);
        }
        return _results;
      })());
      return expect(this.log.limit.count).toBe(2);
    });
    describe('separate lines', function() {
      beforeEach(function() {
        var num;
        return this.html = this.render((function() {
          var _i, _results;
          _results = [];
          for (num = _i = 1; _i <= 2; num = ++_i) {
            _results.push([num, 'foo\n']);
          }
          return _results;
        })());
      });
      it('limits after the given max_lines', function() {
        return expect(this.log.limit.limited).toBe(true);
      });
      it('does not limit before the given max_lines', function() {
        return expect(this.html).toMatch(/<span id="2-0">/);
      });
      return it('limits after the given max_lines', function() {
        return expect(this.html).not.toMatch(/<span id="3-0">/);
      });
    });
    describe('joined lines (1)', function() {
      beforeEach(function() {
        return this.html = this.render([[0, 'foo\nbar\n'], [1, 'baz\n']]);
      });
      it('limits after the given max_lines', function() {
        return expect(this.log.limit.limited).toBe(true);
      });
      it('does not limit before the given max_lines', function() {
        return expect(this.html).toMatch(/<span id="0-1">/);
      });
      return it('limits after the given max_lines', function() {
        return expect(this.html).not.toMatch(/<span id="1-0">/);
      });
    });
    describe('joined lines (2)', function() {
      beforeEach(function() {
        return this.html = this.render([[0, 'foo\n'], [1, 'bar\nbaz\n']]);
      });
      it('limits after the given max_lines', function() {
        return expect(this.log.limit.limited).toBe(true);
      });
      it('does not limit before the given max_lines', function() {
        return expect(this.html).toMatch(/<span id="1-0">/);
      });
      return it('limits after the given max_lines', function() {
        return expect(this.html).not.toMatch(/<span id="1-1">/);
      });
    });
    return describe('joined lines (3)', function() {
      beforeEach(function() {
        return this.html = this.render([[0, 'foo\nbar\nbaz\n']]);
      });
      it('limits after the given max_lines', function() {
        return expect(this.log.limit.limited).toBe(true);
      });
      it('does not limit before the given max_lines', function() {
        return expect(this.html).toMatch(/<span id="0-1">/);
      });
      return it('limits after the given max_lines', function() {
        return expect(this.html).not.toMatch(/<span id="0-2">/);
      });
    });
  });

}).call(this);
