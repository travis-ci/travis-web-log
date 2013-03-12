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
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      this.render = function(parts) {
        return render(this, parts);
      };
      return this.html = strip('<p>\n  <span id="0-0-0" class="hidden"></span>\n  <span id="0-1-0" class="hidden">1%</span>\n  <span id="1-0-0" class="hidden"></span>\n  <span id="1-1-0" class="hidden"></span>\n  <span id="2-0-0" class="hidden"></span>\n  <span id="2-1-0">Done.</span>\n</p>');
    });
    it('clears the line if the carriage return sits on the next part (ordered)', function() {
      return expect(this.render([[0, '0%\r1%'], [1, '\r2%\r'], [2, '\rDone.']])).toBe(this.html);
    });
    it('clears the line if the carriage return sits on the next part (unordered, 1)', function() {
      return expect(this.render([[1, '\r2%\r'], [2, '\rDone.'], [0, '0%\r1%']])).toBe(this.html);
    });
    it('clears the line if the carriage return sits on the next part (unordered, 3)', function() {
      return expect(this.render([[2, '\rDone.'], [1, '\r2%\r'], [0, '0%\r1%']])).toBe(this.html);
    });
    it('simulating git clone', function() {
      return rescueing(this, function() {
        var html, lines;
        html = strip('<p><span id="0-0-0">Cloning into \'jsdom\'...</span></p>\n<p><span id="1-0-0">remote: Counting objects: 13358, done.</span></p>\n<p>\n  <span id="2-0-0" class="hidden"></span>\n  <span id="3-0-0" class="hidden"></span>\n  <span id="4-0-0" class="hidden"></span>\n  <span id="5-0-0" class="hidden"></span>\n  <span id="6-0-0">remote: Compressing objects 100% (5/5), done.</span></p>\n<p>\n  <span id="7-0-0" class="hidden"></span>\n  <span id="8-0-0" class="hidden"></span>\n  <span id="9-0-0" class="hidden"></span>\n  <span id="10-0-0" class="hidden"></span>\n  <span id="11-0-0">Receiving objects 100% (5/5), done.</span></p>\n<p>\n  <span id="12-0-0" class="hidden"></span>\n  <span id="13-0-0" class="hidden"></span>\n  <span id="14-0-0" class="hidden"></span>\n  <span id="15-0-0" class="hidden"></span>\n  <span id="16-0-0">Resolving deltas: 100% (5/5), done.</span>\n</p>\n<p><span id="17-0-0">Something else.</span></p>');
        lines = progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\e[K\n" : "   \e[K\r";
          return [ix + 2, "remote: Compressing objects " + count + "% (" + curr + "/" + total + ")" + end];
        });
        lines = lines.concat(progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\n" : "   \r";
          return [ix + 7, "Receiving objects " + count + "% (" + curr + "/" + total + ")" + end];
        }));
        lines = lines.concat(progress(5, function(ix, count, curr, total) {
          var end;
          end = count === 100 ? ", done.\n" : "   \r";
          return [ix + 12, "Resolving deltas: " + count + "% (" + curr + "/" + total + ")" + end];
        }));
        lines = [[0, "Cloning into 'jsdom'...\n"], [1, "remote: Counting objects: 13358, done.\e[K\n"]].concat(lines);
        lines = lines.concat([[17, 'Something else.']]);
        return expect(this.render(lines)).toBe(html);
      });
    });
    return it('random part sizes w/ dot output', function() {
      var html, parts;
      html = strip('<p>\n  <span id="178-0-0" class="green">.</span>\n  <span id="179-0-0" class="green">.</span>\n  <span id="180-0-0" class="green">.</span>\n  <span id="180-0-1" class="yellow">*</span>\n  <span id="180-0-2" class="yellow">*</span>\n  <span id="181-0-0" class="yellow">*</span>\n</p>');
      parts = [[178, "\u001b[32m.\u001b[0m"], [179, "\u001b[32m.\u001b[0m"], [180, "\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"], [181, "\u001b[33m*\u001b[0m"]];
      return expect(this.render(parts)).toBe(html);
    });
  });

}).call(this);
