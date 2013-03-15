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
    return describe('renders a bunch of lines', function() {
      beforeEach(function() {
        return this.html = strip('<p><span id="0-0-0">foo</span></p>\n<div id="1-0" class="fold-start fold active"><span class="fold-name">install</span>\n  <p><span id="2-0-0">bar</span></p>\n  <p><span id="3-0-0">baz</span></p>\n  <p><span id="4-0-0">buz</span></p>\n</div>\n<div id="5-0" class="fold-end"></div>\n<p><span id="6-0-0">bum</span></p>');
      });
      return it('ordered', function() {
        return rescueing(this, function() {
          return console.log(format(this.render([[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']])));
        });
      });
    });
  });

}).call(this);
