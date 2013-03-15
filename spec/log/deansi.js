(function() {
  var progress;

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
    var format;
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    format = function(html) {
      return html.replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span');
    };
    return it('foo', function() {
      return rescueing(this, function() {
        return console.log(format(this.render([[0, 'foo'], [3, 'baz'], [2, '\r'], [1, 'bar']])));
      });
    });
  });

}).call(this);
