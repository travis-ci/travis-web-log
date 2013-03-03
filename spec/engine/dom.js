(function() {

  describe('Log.Dom', function() {
    var FOLD_END, FOLD_START, rescueing, strip;
    FOLD_START = 'fold:start:install\r\n';
    FOLD_END = 'fold:end:install\r\n';
    strip = function(string) {
      return string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '');
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
        this.log = new Log(Log.Dom);
        this.log.listeners.push(new Log.FragmentRenderer);
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
    return describe('folds', function() {
      it('renders an opening fold tag', function() {
        var html;
        html = '<div id="0-0" class="fold-start"><span class="fold-name">install</span></div>';
        return expect(this.render([[0, FOLD_START]])).toBe(html);
      });
      it('renders an closing fold tag', function() {
        var html;
        html = '<div id="0-0" class="fold-end"></div>';
        return expect(this.render([[0, FOLD_END]])).toBe(html);
      });
      return describe('renders a bunch of lines', function() {
        beforeEach(function() {
          return this.html = strip('<p><span id="0-0-0">foo</span></p>\n<div id="1-0" class="fold-start"><span class="fold-name">install</span></div>\n<p><span id="2-0-0">bar</span></p>\n<p><span id="3-0-0">baz</span></p>\n<p><span id="4-0-0">buz</span></p>\n<div id="5-0" class="fold-end"></div>\n<p><span id="6-0-0">bum</span></p>');
        });
        it('ordered', function() {
          return expect(this.render([[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']])).toBe(this.html);
        });
        it('unordered (1)', function() {
          return expect(this.render([[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']])).toBe(this.html);
        });
        it('unordered (1)', function() {
          return expect(this.render([[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']])).toBe(this.html);
        });
        return it('unordered (1)', function() {
          return expect(this.render([[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']])).toBe(this.html);
        });
      });
    });
  });

}).call(this);
