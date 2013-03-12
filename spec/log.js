(function() {

  describe('Log', function() {
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    describe('set', function() {
      beforeEach(function() {
        return this.log.set(0, '.');
      });
      it('adds a part', function() {
        return expect(this.log.children.first.id).toBe('0');
      });
      it('adds a line', function() {
        return expect(this.log.children.first.children.first.id).toBe('0-0');
      });
      return it('adds a span to the line', function() {
        return expect(this.log.children.first.children.first.children.first.id).toBe('0-0-0');
      });
    });
    describe('escaping', function() {
      return it('escapes a script tag', function() {
        var html;
        html = strip('<p><span id="0-0-0">&lt;script&gt;alert("hi!")&lt;/script&gt;</span></p>');
        return expect(this.render([[0, '<script>alert("hi!")</script>']])).toBe(html);
      });
    });
    describe('lines', function() {
      beforeEach(function() {
        return this.html = strip('<p><span id="0-0-0">foo</span></p>\n<p><span id="1-0-0">bar</span></p>\n<p><span id="2-0-0">baz</span></p>');
      });
      it('ordered', function() {
        return expect(this.render([[0, 'foo\n'], [1, 'bar\n'], [2, 'baz\n']])).toBe(this.html);
      });
      it('unordered (1)', function() {
        return expect(this.render([[0, 'foo\n'], [2, 'baz\n'], [1, 'bar\n']])).toBe(this.html);
      });
      it('unordered (2)', function() {
        return expect(this.render([[1, 'bar\n'], [0, 'foo\n'], [2, 'baz\n']])).toBe(this.html);
      });
      it('unordered (3)', function() {
        return expect(this.render([[1, 'bar\n'], [2, 'baz\n'], [0, 'foo\n']])).toBe(this.html);
      });
      it('unordered (4)', function() {
        return expect(this.render([[2, 'baz\n'], [0, 'foo\n'], [1, 'bar\n']])).toBe(this.html);
      });
      return it('unordered (5)', function() {
        return expect(this.render([[2, 'baz\n'], [1, 'bar\n'], [0, 'foo\n']])).toBe(this.html);
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
    return it('inserting a terminated line after a number of unterminated parts', function() {
      var html;
      html = strip('<p><span id="1-0-0">.</span><span id="2-0-0">end</span></p>\n<p><span id="3-0-0">end</span></p>\n<p><span id="4-0-0">.</span><span id="5-0-0">.</span><span id="6-0-0">.</span><span id="7-0-0">end</span></p>');
      return expect(this.render([[5, '.'], [4, '.'], [1, '.'], [2, 'end\n'], [3, 'end\n'], [6, '.'], [7, 'end\n']])).toBe(html);
    });
  });

}).call(this);
