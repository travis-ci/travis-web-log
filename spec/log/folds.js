(function() {

  describe('folds', function() {
    var FOLD_END, FOLD_START;
    FOLD_START = 'fold:start:install\r\n';
    FOLD_END = 'fold:end:install\r\n';
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    describe('renders a bunch of lines', function() {
      beforeEach(function() {
        return this.html = strip('<p><span id="0-0">foo</span></p>\n<div id="fold-start-install" class="fold-start fold active"><span class="fold-name">install</span>\n  <p><span id="2-0">bar</span></p>\n  <p><span id="3-0">baz</span></p>\n  <p><span id="4-0">buz</span></p>\n</div>\n<div id="fold-end-install" class="fold-end"></div>\n<p><span id="6-0">bum</span></p>');
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
    it('inserting an unterminated part in front of a fold', function() {
      var html, parts;
      parts = [[2, "travis_fold:start:install\r$ ./install\r\ntravis_fold:end:install\r"], [1, "bar"]];
      html = strip('<p><span id="1-0">bar</span></p>\n<div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span>\n<p><span id="2-1">$ ./install</span></p></div>\n<div id="fold-end-install" class="fold-end"></div>');
      return expect(this.render(parts)).toBe(html);
    });
    it('inserting a terminated line after a number of unterminated parts within a fold', function() {
      var html;
      html = strip('<div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span>\n  <p><a></a><span id="1-0">.</span><span id="2-0">end</span></p>\n</div>\n<div id="fold-end-install" class="fold-end"></div>');
      return expect(this.render([[3, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n'], [1, '.'], [2, 'end\n']])).toBe(html);
    });
    it('an empty fold', function() {
      var html;
      html = strip('<div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span></div>\n<div id="fold-end-install" class="fold-end"></div>');
      return expect(this.render([[1, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n']])).toBe(html);
    });
    return it('inserting a fold after a span that will be split out later', function() {
      var html, parts;
      html = strip('<p><span id="1-0">first</span></p>\n<p><span id="2-0">.</span></p>\n<div id="fold-start-after_script" class="fold-start fold"><span class="fold-name">after_script</span>\n  <p><span id="3-1">folded</span></p>\n</div>\n<div id="fold-end-after_script" class="fold-end"></div>\n<p><span id="4-0">last</span></p>');
      parts = [[2, '.'], [4, 'last\n'], [3, 'fold:start:after_script\rfolded\r\nfold:end:after_script\r'], [1, 'first\n']];
      return expect(this.render(parts)).toBe(html);
    });
  });

}).call(this);
