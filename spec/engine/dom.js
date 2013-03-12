(function() {

  describe('Log.Dom', function() {
    return beforeEach(function() {
      return rescueing(this, function() {
        while (log.firstChild) {
          log.removeChild(log.firstChild);
        }
        this.log = Log.create({
          engine: Log.Dom,
          listeners: [new Log.FragmentRenderer]
        });
        return this.render = function(parts) {
          return render(this, parts);
        };
      });
    });
  });

}).call(this);
