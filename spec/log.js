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
    return it('foo', function() {
      return rescueing(this, function() {
        var html, text;
        text = require('fs').readFileSync('log.3.reduced.txt', 'utf-8');
        html = this.render([[0, text]]);
        console.log(format(html));
        return dump(this.log);
      });
    });
  });

}).call(this);
