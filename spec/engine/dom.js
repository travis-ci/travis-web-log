(function() {

  describe('Log.Dom', function() {
    var FOLD_END, FOLD_START, format, rescueing, strip;
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
    return it('foo', function() {
      return rescueing(this, function() {
        var html, parts;
        parts = eval(require('fs').readFileSync('./log.parts.reduced.txt', 'utf-8'));
        return html = this.render(parts);
      });
    });
  });

}).call(this);
