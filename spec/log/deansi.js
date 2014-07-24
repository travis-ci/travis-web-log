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
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    return describe('travis_time and travis_fold', function() {
      it('works (1)', function() {
        var html, parts;
        html = strip('<div id="fold-start-git.1" class="fold-start fold active">\n  <span class="fold-name">git.1</span>\n  <p>\n    <span id="0-1" class="clears"></span>\n    <span id="0-2">$ git clone git://github.com/travis-repos/test-project-1.git</span>\n  </p>\n  <p>\n    <span id="1-0">Cloning into "travis-repos/test-project-1"...</span>\n  </p>\n  <p>\n    <span id="2-0" class="clears"></span>\n  </p>\n</div>\n<div id="fold-end-git.1" class="fold-end"></div>\n<p>\n  <span id="2-2" class="clears"></span>\n  <span id="2-3">$ cd travis-repos/test-project-1</span>\n</p>\n<p>\n  <span id="3-0" class="clears"></span>\n</p>');
        parts = [[0, 'travis_fold:start:git.1\r\x1b[0Ktravis_time:start\r\x1b[0K$ git clone git://github.com/travis-repos/test-project-1.git\r\n'], [1, 'Cloning into "travis-repos/test-project-1"...\r\n'], [2, 'travis_time:finish:start=1406198200403308535,finish=1406198200512171436,duration=108862901\r\x1b[0Ktravis_fold:end:git.1\r\x1b[0Ktravis_time:start\r\x1b[0K$ cd travis-repos/test-project-1\r\n'], [3, 'travis_time:finish:start=1406198200519336670,finish=1406198200526430974,duration=7094304\r\x1b[0K']];
        return expect(this.render(parts)).toBe(html);
      });
      return it('works (2)', function() {
        var html, part, parts;
        html = strip('<p>\n  <span id="0-0"></span>\n</p>\n<p>\n  <span id="0-1"></span>\n</p>\n<p>\n  <span id="0-2" class="clears"></span>\n  <span id="0-3">$ rvm use default</span>\n</p>\n<p>\n  <span id="0-4"></span>\n</p>\n<p>\n  <span id="0-5" class="green">Using /home/travis/.rvm/gems/ruby-1.9.3-p545</span>\n  <span id="0-6"></span>\n</p>\n<p>\n  <span id="0-7"></span>\n</p>\n<p>\n  <span id="0-8" class="clears"></span>\n  <span id="0-9">$ export BUNDLE_GEMFILE=$PWD/Gemfile</span>\n</p>');
        part = '\r\n\ntravis_time:start\r\x1b[0K$ rvm use default\r\n\n\x1b[32mUsing /home/travis/.rvm/gems/ruby-1.9.3-p545\x1b[0m\r\n\ntravis_time:finish:start=1406198200554511643,finish=1406198200768749441,duration=214237798\r\x1b[0K$ export BUNDLE_GEMFILE=$PWD/Gemfile\r\n';
        parts = [[0, part]];
        return expect(this.render(parts)).toBe(html);
      });
    });
  });

}).call(this);
