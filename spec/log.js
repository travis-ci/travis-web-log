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
    return describe('multiple lines on the same part', function() {
      return it('unordered (4, chunked)', function() {
        return rescueing(this, function() {
          var html;
          html = strip('<p><span id="1-0-0"></span></p>\n<p><span id="1-1-0">foo</span></p>\n<p><span id="2-1-0">bar</span><span id="3-0-0"></span></p>');
          this.render([[3, '\n'], [1, '\nfoo'], [2, '\n']]);
          return dump(this.log);
        });
      });
    });
  });

}).call(this);
