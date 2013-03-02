(function() {

  describe('Log.Chunks', function() {
    var html, rescueing;
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log(Log.Chunks);
      return this.log.listeners.push(new Log.FragmentRenderer);
    });
    html = function() {
      return document.firstChild.innerHTML;
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
    return describe('set', function() {
      it('renders an unterminated chunk', function() {
        this.log.set(0, 'foo');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>');
      });
      it('renders a bunch of unterminated chunks', function() {
        this.log.set(0, '.');
        this.log.set(1, '.');
        this.log.set(2, '.');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>');
      });
      it('renders a bunch of unordered, unterminated chunks (1)', function() {
        this.log.set(2, '.');
        this.log.set(0, '.');
        this.log.set(1, '.');
        return expect(html()).toBe('<p id="2-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>');
      });
      it('renders a bunch of unordered, unterminated chunks (2)', function() {
        this.log.set(1, '.');
        this.log.set(0, '.');
        this.log.set(2, '.');
        return expect(html()).toBe('<p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>');
      });
      it('renders a bunch of unordered, unterminated chunks (3)', function() {
        this.log.set(1, '.');
        this.log.set(2, '.');
        this.log.set(0, '.');
        return expect(html()).toBe('<p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>');
      });
      it('renders a bunch of lines', function() {
        this.log.set(0, 'foo\n');
        this.log.set(1, 'bar\n');
        this.log.set(2, 'baz\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="1-0"><a></a><span id="1-0-0">bar</span></p>\n<p id="2-0"><a></a><span id="2-0-0">baz</span></p>'.replace(/\n/g, ''));
      });
      it('renders a bunch of unordered lines (1)', function() {
        this.log.set(0, 'foo\n');
        this.log.set(1, 'bar\n');
        this.log.set(2, 'baz\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="1-0"><a></a><span id="1-0-0">bar</span></p>\n<p id="2-0"><a></a><span id="2-0-0">baz</span></p>'.replace(/\n/g, ''));
      });
      it('renders a bunch of unordered lines (2)', function() {
        this.log.set(1, 'bar\n');
        this.log.set(0, 'foo\n');
        this.log.set(2, 'baz\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="1-0"><a></a><span id="1-0-0">bar</span></p>\n<p id="2-0"><a></a><span id="2-0-0">baz</span></p>'.replace(/\n/g, ''));
      });
      it('renders a bunch of unordered lines (3)', function() {
        this.log.set(2, 'baz\n');
        this.log.set(0, 'foo\n');
        this.log.set(1, 'bar\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="1-0"><a></a><span id="1-0-0">bar</span></p>\n<p id="2-0"><a></a><span id="2-0-0">baz</span></p>'.replace(/\n/g, ''));
      });
      it('simulating test dot output', function() {
        this.log.set(0, 'foo\n');
        this.log.set(1, '.');
        this.log.set(2, '.');
        this.log.set(3, '.\n');
        this.log.set(4, 'bar\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p id="4-0"><a></a><span id="4-0-0">bar</span></p>'.replace(/\n/g, ''));
      });
      it('terminator out of order', function() {
        this.log.set(0, '.');
        this.log.set(2, 'bar\n');
        this.log.set(1, '.\n');
        return expect(html()).toBe('<p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span></p>\n<p id="2-0"><a></a><span id="2-0-0">bar</span></p>'.replace(/\n/g, ''));
      });
      it('simulating unordered test dot output (1)', function() {
        this.log.set(0, 'foo\n');
        this.log.set(3, '.\n');
        this.log.set(1, '.');
        this.log.set(2, '.');
        this.log.set(4, 'bar\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p id="4-0"><a></a><span id="4-0-0">bar</span></p>'.replace(/\n/g, ''));
      });
      it('simulating unordered test dot output (2)', function() {
        this.log.set(4, 'bar\n');
        this.log.set(1, '.');
        this.log.set(0, 'foo\n');
        this.log.set(3, '.\n');
        this.log.set(2, '.');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p id="4-0"><a></a><span id="4-0-0">bar</span></p>'.replace(/\n/g, ''));
      });
      return it('simulating unordered test dot output (3)', function() {
        this.log.set(4, 'bar\n');
        this.log.set(3, '.\n');
        this.log.set(1, '.');
        this.log.set(2, '.');
        this.log.set(0, 'foo\n');
        return expect(html()).toBe('<p id="0-0"><a></a><span id="0-0-0">foo</span></p>\n<p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>\n<p id="4-0"><a></a><span id="4-0-0">bar</span></p>'.replace(/\n/g, ''));
      });
    });
  });

}).call(this);
