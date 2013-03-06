(function() {

  describe('Log.Dom', function() {
    var FOLD_END, FOLD_START, format, progress, rescueing, strip;
    FOLD_START = 'fold:start:install\r\n';
    FOLD_END = 'fold:end:install\r\n';
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
          listeners: [new Log.FragmentRenderer]
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
    describe('lines', function() {
      var HTML;
      HTML = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">baz</span></p>');
      it('ordered', function() {
        return expect(this.render([[0, 'foo\n'], [1, 'bar\n'], [2, 'baz\n']])).toBe(HTML);
      });
      it('unordered (1)', function() {
        return expect(this.render([[0, 'foo\n'], [2, 'baz\n'], [1, 'bar\n']])).toBe(HTML);
      });
      it('unordered (2)', function() {
        return expect(this.render([[1, 'bar\n'], [0, 'foo\n'], [2, 'baz\n']])).toBe(HTML);
      });
      it('unordered (3)', function() {
        return expect(this.render([[1, 'bar\n'], [2, 'baz\n'], [0, 'foo\n']])).toBe(HTML);
      });
      it('unordered (4)', function() {
        return expect(this.render([[2, 'baz\n'], [0, 'foo\n'], [1, 'bar\n']])).toBe(HTML);
      });
      return it('unordered (5)', function() {
        return expect(this.render([[2, 'baz\n'], [1, 'bar\n'], [0, 'foo\n']])).toBe(HTML);
      });
    });
    describe('multiple lines on the same part', function() {
      it('ordered (1)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="0-1-0">bar</span></p>\n<p><span id="0-2-0">baz</span></p>\n<p><span id="1-0-0">buz</span></p>\n<p><span id="1-1-0">bum</span></p>');
        return expect(this.render([[0, 'foo\nbar\nbaz\n'], [1, 'buz\nbum']])).toBe(html);
      });
      it('ordered (2)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="1-1-0">baz</span></p>\n<p><span id="2-0-0">buz</span></p>\n<p><span id="2-1-0">bum</span></p>');
        return expect(this.render([[0, 'foo\n'], [1, 'bar\nbaz\n'], [2, 'buz\nbum']])).toBe(html);
      });
      it('ordered (2, chunked)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="0-1-0">bar</span><span id="1-0-0"></span></p>\n<p><span id="1-1-0">baz</span></p>\n<p><span id="1-2-0">buz</span><span id="2-0-0"></span></p>\n<p><span id="2-1-0">bum</span></p>');
        return expect(this.render([[0, 'foo\nbar'], [1, '\nbaz\nbuz'], [2, '\nbum']])).toBe(html);
      });
      it('ordered (3, chunked)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>\n<p><span id="1-1-0">bar</span></p>\n<p><span id="1-2-0">baz</span></p>\n<p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>\n<p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>\n<p><span id="4-0-0"></span></p>');
        return expect(this.render([[0, 'foo'], [1, '\nbar\nbaz\nbuz'], [2, '\nbum'], [3, '\n'], [4, '\n']])).toBe(html);
      });
      it('unordered (1)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="1-1-0">baz</span></p>\n<p><span id="2-0-0">buz</span></p>\n<p><span id="2-1-0">bum</span></p>');
        return expect(this.render([[0, 'foo\n'], [2, 'buz\nbum'], [1, 'bar\nbaz\n']])).toBe(html);
      });
      it('unordered (2)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="1-1-0">baz</span></p>\n<p><span id="2-0-0">buz</span></p>\n<p><span id="2-1-0">bum</span></p>');
        return expect(this.render([[2, 'buz\nbum'], [0, 'foo\n'], [1, 'bar\nbaz\n']])).toBe(html);
      });
      it('unordered (3)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="1-1-0">baz</span></p>\n<p><span id="2-0-0">buz</span></p>\n<p><span id="2-1-0">bum</span></p>');
        return expect(this.render([[2, 'buz\nbum'], [1, 'bar\nbaz\n'], [0, 'foo\n']])).toBe(html);
      });
      it('unordered (4, chunked)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>\n<p><span id="1-1-0">bar</span></p>\n<p><span id="1-2-0">baz</span></p>\n<p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>\n<p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>\n<p><span id="4-0-0"></span></p>');
        return expect(this.render([[3, '\n'], [1, '\nbar\nbaz\nbuz'], [4, '\n'], [2, '\nbum'], [0, 'foo']])).toBe(html);
      });
      it('unordered (5, chunked)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>\n<p><span id="1-1-0">bar</span></p>\n<p><span id="1-2-0">baz</span></p>\n<p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>\n<p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>\n<p><span id="4-0-0"></span></p>');
        return expect(this.render([[1, '\nbar\nbaz\nbuz'], [0, 'foo'], [3, '\n'], [2, '\nbum'], [4, '\n']])).toBe(html);
      });
      return it('unordered (6, chunked)', function() {
        var html;
        html = strip('<p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>\n<p><span id="1-1-0">bar</span></p>\n<p><span id="1-2-0">baz</span></p>\n<p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>\n<p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>\n<p><span id="4-0-0"></span></p>');
        return expect(this.render([[4, '\n'], [3, '\n'], [2, '\nbum'], [1, '\nbar\nbaz\nbuz'], [0, 'foo']])).toBe(html);
      });
    });
    describe('unterminated chunks', function() {
      it('ordered', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[0, '.'], [1, '.'], [2, '.']])).toBe(html);
      });
      it('unordered (1)', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[0, '.'], [2, '.'], [1, '.']])).toBe(html);
      });
      it('unordered (2)', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[1, '.'], [0, '.'], [2, '.']])).toBe(html);
      });
      it('unordered (3)', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[1, '.'], [2, '.'], [0, '.']])).toBe(html);
      });
      it('unordered (4)', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[2, '.'], [1, '.'], [0, '.']])).toBe(html);
      });
      return it('unordered (5)', function() {
        var html;
        html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>';
        return expect(this.render([[2, '.'], [0, '.'], [1, '.']])).toBe(html);
      });
    });
    describe('simulating test dot output (10 parts, incomplete permutations)', function() {
      it('ordered', function() {
        var data, html;
        data = [[0, 'foo\n'], [1, 'bar\n'], [2, '.'], [3, '.'], [4, '.\n'], [5, 'baz\n'], [6, 'buz\n'], [7, '.'], [8, '.'], [9, '.']];
        html = strip('<p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>\n<p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>\n<p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>');
        return expect(this.render(data)).toBe(html);
      });
      it('unordered (1)', function() {
        var data, html;
        data = [[0, 'foo\n'], [2, '.'], [1, 'bar\n'], [4, '.\n'], [3, '.'], [6, 'buz\n'], [5, 'baz\n'], [8, '.'], [7, '.'], [9, '.']];
        html = strip('<p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>\n<p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>\n<p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>');
        return expect(this.render(data)).toBe(html);
      });
      it('unordered (2)', function() {
        var data, html;
        data = [[0, 'foo\n'], [3, '.'], [1, 'bar\n'], [5, 'baz\n'], [2, '.'], [7, '.'], [4, '.\n'], [6, 'buz\n'], [9, '.'], [8, '.']];
        html = strip('<p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>\n<p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>\n<p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>');
        return expect(this.render(data)).toBe(html);
      });
      it('unordered (3)', function() {
        var data, html;
        data = [[7, '.'], [9, '.'], [4, '.\n'], [8, '.'], [6, 'buz\n'], [2, '.'], [5, 'baz\n'], [0, 'foo\n'], [3, '.'], [1, 'bar\n']];
        html = strip('<p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>\n<p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>\n<p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>');
        return expect(this.render(data)).toBe(html);
      });
      return it('unordered (4)', function() {
        var data, html;
        data = [[9, '.'], [8, '.'], [7, '.'], [6, 'buz\n'], [5, 'baz\n'], [4, '.\n'], [3, '.'], [2, '.'], [1, 'bar\n'], [0, 'foo\n']];
        html = strip('<p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>\n<p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>\n<p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>');
        return expect(this.render(data)).toBe(html);
      });
    });
    describe('simulating test dot output (5 parts, complete permutations)', function() {
      beforeEach(function() {
        return this.html = {
          1: strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p><span id="4-0-0">bar</span></p>'),
          2: strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p><span id="4-0-0">bar</span></p>'),
          3: strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p><span id="4-0-0">bar</span></p>')
        };
      });
      it('ordered', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (1)', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (2)', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (3)', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.']])).toBe(this.html[1]);
      });
      it('unordered (4)', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (4)', function() {
        return expect(this.render([[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (5)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (6)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (7)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (8)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.']])).toBe(this.html[2]);
      });
      it('unordered (9)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (10)', function() {
        return expect(this.render([[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (11)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (12)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (13)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (14)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (15)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (16)', function() {
        return expect(this.render([[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (18)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (19)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (20)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (21)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (22)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (23)', function() {
        return expect(this.render([[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (24)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (25)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (26)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (27)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.']])).toBe(this.html[1]);
      });
      it('unordered (28)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (29)', function() {
        return expect(this.render([[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (30)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (31)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (32)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (33)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[1]);
      });
      it('unordered (34)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (35)', function() {
        return expect(this.render([[1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (36)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (37)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']])).toBe(this.html[1]);
      });
      it('unordered (38)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[1]);
      });
      it('unordered (39)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[1]);
      });
      it('unordered (40)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']])).toBe(this.html[1]);
      });
      it('unordered (41)', function() {
        return expect(this.render([[1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']])).toBe(this.html[1]);
      });
      it('unordered (42)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (43)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (44)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (45)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (46)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (47)', function() {
        return expect(this.render([[1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (48)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (49)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (50)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (51)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.']])).toBe(this.html[2]);
      });
      it('unordered (52)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (53)', function() {
        return expect(this.render([[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (54)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (55)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (56)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (57)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[2]);
      });
      it('unordered (58)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (59)', function() {
        return expect(this.render([[2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (60)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (61)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']])).toBe(this.html[2]);
      });
      it('unordered (62)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[2]);
      });
      it('unordered (63)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[2]);
      });
      it('unordered (64)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']])).toBe(this.html[2]);
      });
      it('unordered (65)', function() {
        return expect(this.render([[2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']])).toBe(this.html[2]);
      });
      it('unordered (66)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (67)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (68)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (69)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (71)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (72)', function() {
        return expect(this.render([[2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (73)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (74)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (75)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (76)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (77)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (78)', function() {
        return expect(this.render([[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (79)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (80)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (81)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (82)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (83)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (84)', function() {
        return expect(this.render([[3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (85)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (86)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (87)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']])).toBe(this.html[3]);
      });
      it('unordered (88)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (89)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (90)', function() {
        return expect(this.render([[3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (91)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (92)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (92)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (93)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (94)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (95)', function() {
        return expect(this.render([[3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (96)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (97)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (98)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (99)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (100)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (101)', function() {
        return expect(this.render([[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (102)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (103)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (104)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (105)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (106)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (107)', function() {
        return expect(this.render([[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']])).toBe(this.html[1]);
      });
      it('unordered (108)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (109)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (110)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n']])).toBe(this.html[3]);
      });
      it('unordered (111)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n']])).toBe(this.html[2]);
      });
      it('unordered (112)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.']])).toBe(this.html[2]);
      });
      it('unordered (113)', function() {
        return expect(this.render([[4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n']])).toBe(this.html[2]);
      });
      it('unordered (114)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (115)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.']])).toBe(this.html[3]);
      });
      it('unordered (116)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.']])).toBe(this.html[3]);
      });
      it('unordered (117)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
      it('unordered (118)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.']])).toBe(this.html[3]);
      });
      return it('unordered (119)', function() {
        return expect(this.render([[4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n']])).toBe(this.html[3]);
      });
    });
    describe('folds', function() {
      describe('renders a bunch of lines', function() {
        beforeEach(function() {
          return this.html = strip('<p><span id="0-0-0">foo</span></p>\n<div id="fold-start-install" class="fold-start"><span class="fold-name">install</span></div>\n<p><span id="2-0-0">bar</span></p>\n<p><span id="3-0-0">baz</span></p>\n<p><span id="4-0-0">buz</span></p>\n<div id="fold-end-install" class="fold-end"></div>\n<p><span id="6-0-0">bum</span></p>');
        });
        it('ordered', function() {
          return expect(this.render([[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']])).toBe(this.html);
        });
        it('unordered (1)', function() {
          return expect(this.render([[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']])).toBe(this.html);
        });
        it('unordered (2)', function() {
          return expect(this.render([[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']])).toBe(this.html);
        });
        return it('unordered (3)', function() {
          return expect(this.render([[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']])).toBe(this.html);
        });
      });
      return describe('with Log.Folds listening', function() {
        beforeEach(function() {
          this.log.listeners.push(new Log.Folds);
          return this.html = strip('<p><span id="0-0-0">foo</span></p>\n<div id="fold-start-install" class="fold-start fold">\n  <span class="fold-name">install</span>\n  <p><span id="2-0-0">bar</span></p>\n  <p><span id="3-0-0">baz</span></p>\n  <p><span id="4-0-0">buz</span></p>\n</div>\n<div id="fold-end-install" class="fold-end"></div>\n<p><span id="6-0-0">bum</span></p>');
        });
        it('ordered', function() {
          return expect(this.render([[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']])).toBe(this.html);
        });
        it('unordered (1)', function() {
          return expect(this.render([[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']])).toBe(this.html);
        });
        it('unordered (2)', function() {
          return expect(this.render([[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']])).toBe(this.html);
        });
        return it('unordered (3)', function() {
          return expect(this.render([[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']])).toBe(this.html);
        });
      });
    });
    progress = function(total, callback) {
      var count, curr, ix, part, result, step, _i;
      total -= 1;
      result = [];
      step = Math.ceil(100 / total);
      part = Math.ceil(total / 100);
      curr = 1;
      ix = 0;
      for (count = _i = 1; _i <= 99; count = _i += step) {
        count = count.toString();
        count = Array(4 - count.length).join(' ') + count;
        result.push(callback(ix, count, curr, total));
        ix += 1;
        curr += part;
        if (curr > total) {
          curr = total;
        }
      }
      result.push(callback(ix, 100, total + 1, total + 1));
      return result;
    };
    describe('deansi', function() {
      return it('simulating git clone', function() {
        var html, lines;
        html = strip('<p><span id="0-0-0">Cloning into \'jsdom\'...</span></p>\n<p><span id="1-0-0">remote: Counting objects: 13358, done.</span></p>\n<p style="display: none;"><span id="2-0-0">remote: Compressing objects   1% (1/4)   </span></p>\n<p style="display: none;"><span id="3-0-0">remote: Compressing objects  26% (2/4)   </span></p>\n<p style="display: none;"><span id="4-0-0">remote: Compressing objects  51% (3/4)   </span></p>\n<p style="display: none;"><span id="5-0-0">remote: Compressing objects  76% (4/4)   </span></p>\n<p><span id="6-0-0">remote: Compressing objects 100% (5/5), done.</span></p>\n<p style="display: none;"><span id="7-0-0">Receiving objects   1% (1/4)   </span></p>\n<p style="display: none;"><span id="8-0-0">Receiving objects  26% (2/4)   </span></p>\n<p style="display: none;"><span id="9-0-0">Receiving objects  51% (3/4)   </span></p>\n<p style="display: none;"><span id="10-0-0">Receiving objects  76% (4/4)   </span></p>\n<p><span id="11-0-0">Receiving objects 100% (5/5), done.</span></p>\n<p style="display: none;"><span id="12-0-0">Resolving deltas:   1% (1/4)   </span></p>\n<p style="display: none;"><span id="13-0-0">Resolving deltas:  26% (2/4)   </span></p>\n<p style="display: none;"><span id="14-0-0">Resolving deltas:  51% (3/4)   </span></p>\n<p style="display: none;"><span id="15-0-0">Resolving deltas:  76% (4/4)   </span></p>\n<p><span id="16-0-0">Resolving deltas: 100% (5/5), done.</span></p>\n<p><span id="17-0-0">Something else.</span></p>');
        lines = progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\e[K\n" : "   \e[K\r";
          return [ix + 2, "remote: Compressing objects " + count + "% (" + curr + "/" + total + ")" + end];
        });
        lines = lines.concat(progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\n" : "   \r";
          return [ix + 7, "Receiving objects " + count + "% (" + curr + "/" + total + ")" + end];
        }));
        lines = lines.concat(progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\n" : "   \r";
          return [ix + 12, "Resolving deltas: " + count + "% (" + curr + "/" + total + ")" + end];
        }));
        lines = [[0, "Cloning into 'jsdom'...\n"], [1, "remote: Counting objects: 13358, done.\e[K\n"]].concat(lines);
        lines = lines.concat([[17, 'Something else.']]);
        return expect(this.render(lines)).toBe(html);
      });
    });
    return describe('random part sizes w/ dot output', function() {
      return it('foo', function() {
        var html, parts;
        html = strip('<p>\n  <span id="178-0-0" class="green">.</span>\n  <span id="179-0-0" class="green">.</span>\n  <span id="180-0-0" class="green">.</span>\n  <span id="180-0-1" class="yellow">*</span>\n  <span id="180-0-2" class="yellow">*</span>\n  <span id="181-0-0" class="yellow">*</span>\n</p>');
        parts = [[178, "\u001b[32m.\u001b[0m"], [179, "\u001b[32m.\u001b[0m"], [180, "\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"], [181, "\u001b[33m*\u001b[0m"]];
        return expect(this.render(parts)).toBe(html);
      });
    });
  });

}).call(this);
