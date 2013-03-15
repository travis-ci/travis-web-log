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
    return it('inserting a terminated line after a number of unterminated parts', function() {
      var html;
      html = strip('<p><span id="1-0-0">.</span><span id="2-0-0">end</span></p>\n<p><span id="3-0-0">end</span></p>\n<p><span id="4-0-0">.</span><span id="5-0-0">.</span><span id="6-0-0">.</span><span id="7-0-0">end</span></p>');
      return rescueing(this, function() {
        return console.log(format(this.render([[4, '.'], [3, '.'], [1, '.'], [2, 'end\n']])));
      });
    });
  });

}).call(this);
