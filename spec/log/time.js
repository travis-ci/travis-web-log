(function() {

  describe('timing', function() {
    beforeEach(function() {
      while (log.firstChild) {
        log.removeChild(log.firstChild);
      }
      this.log = new Log();
      return this.render = function(parts) {
        return render(this, parts);
      };
    });
    it('timing a command (1)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="0-1">timed</span>\n  <span id="0-2"></span>\n</p>');
      parts = [[0, 'travis_time:start:1234\rtimed\r\ntravis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command (2)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="0-1">timed</span>\n  <span id="1-0"></span>\n</p>');
      parts = [[0, 'travis_time:start:1234\rtimed\r\n'], [1, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command (3)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">timed</span>\n  <span id="2-0"></span>\n</p>');
      parts = [[0, 'travis_time:start:1234\r'], [1, 'timed\r\n'], [2, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command (4)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="0-1">timed</span>\n</p>\n<p><span id="1-0"></span></p>');
      parts = [[1, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [0, 'travis_time:start:1234\rtimed\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command (5)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">timed</span>\n</p>\n<p><span id="2-0"></span></p>');
      parts = [[2, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [1, 'timed\r\n'], [0, 'travis_time:start:1234\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a long running command (1)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">one</span>\n</p>\n<p>\n  <span id="2-0">two</span>\n</p>\n<p>\n  <span id="3-0">three</span>\n  <span id="4-0"></span>\n</p>');
      parts = [[0, 'travis_time:start:1234\r'], [1, 'one\r\n'], [2, 'two\r\n'], [3, 'three\r\n'], [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a long running command (2)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">one</span>\n</p>\n<p>\n  <span id="2-0">two</span>\n</p>\n<p>\n  <span id="3-0">three</span>\n</p>\n<p>\n  <span id="4-0"></span>\n</p>');
      parts = [[0, 'travis_time:start:1234\r'], [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [3, 'three\r\n'], [1, 'one\r\n'], [2, 'two\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a long running command (2)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">one</span>\n</p>\n<p>\n  <span id="2-0">two</span>\n</p>\n<p>\n  <span id="3-0">three</span>\n</p>\n<p>\n  <span id="4-0"></span>\n</p>');
      parts = [[4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [0, 'travis_time:start:1234\r'], [2, 'two\r\n'], [3, 'three\r\n'], [1, 'one\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a long running command (3)', function() {
      var html, parts;
      html = strip('<p>\n  <span id="0-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n  <span id="1-0">one</span>\n</p>\n<p>\n  <span id="2-0">two</span>\n</p>\n<p>\n  <span id="3-0">three</span>\n</p>\n<p>\n  <span id="4-0"></span>\n</p>');
      parts = [[4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [2, 'two\r\n'], [3, 'three\r\n'], [0, 'travis_time:start:1234\r'], [1, 'one\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command witin a fold (1)', function() {
      var html, parts;
      html = strip('<div id="fold-start-after_script" class="fold-start fold">\n  <span class="fold-name">after_script</span>\n  <p>\n    <span id="0-1" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n    <span id="0-2">timed</span>\n    <span id="0-3"></span>\n  </p>\n</div>\n<div id="fold-end-after_script" class="fold-end"></div>\n<p><span id="0-5">outside the fold</span></p>');
      parts = [[0, 'fold:start:after_script\rtravis_time:start:1234\rtimed\r\ntravis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\rfold:end:after_script\routside the fold\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command within a fold (6, realworld)', function() {
      var html, parts;
      html = strip('<div id="fold-start-git.1" class="fold-start fold">\n  <span class="fold-name">git.1</span>\n  <p>\n    <span id="0-1" class="duration" title="This command finished after 417.24 seconds.">417.24</span>\n    <span id="0-2">e[0K$ git clone</span>\n    <span id="0-3"></span>\n  </p>\n</div>\n<div id="fold-end-git.1" class="fold-end"></div>\n<p><span id="0-5">e[0K$ cd travis-repos/test-project-1</span></p>');
      parts = [[0, 'travis_fold:start:git.1\r\e[0Ktravis_time:start:27547\r\e[0K$ git clone\r\ntravis_time:end:27547:start=1407271442112293793,finish=1407271442529529232,duration=417235439\r\e[0Ktravis_fold:end:git.1\r\e[0K$ cd travis-repos/test-project-1\r\n']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command witin a fold (1)', function() {
      var html, parts;
      html = strip('<div id="fold-start-after_script" class="fold-start fold">\n  <span class="fold-name">after_script</span>\n  <p>\n    <span id="1-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n    <span id="2-0">timed</span>\n    <span id="3-0"></span>\n  </p>\n</div>\n<div id="fold-end-after_script" class="fold-end"></div>');
      parts = [[0, 'fold:start:after_script\r'], [1, 'travis_time:start:1234\r'], [2, 'timed\r\n'], [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [4, 'fold:end:after_script\r']];
      return expect(this.render(parts)).toBe(html);
    });
    it('timing a command witin a fold (2)', function() {
      var html, parts;
      html = strip('<div id="fold-start-after_script" class="fold-start fold active">\n  <span class="fold-name">after_script</span>\n  <p>\n    <span id="1-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n    <span id="2-0">timed</span>\n  </p>\n  <p><span id="3-0"></span></p>\n</div>\n<div id="fold-end-after_script" class="fold-end"></div>');
      parts = [[1, 'travis_time:start:1234\r'], [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [2, 'timed\r\n'], [0, 'fold:start:after_script\r'], [4, 'fold:end:after_script\r']];
      return expect(this.render(parts)).toBe(html);
    });
    return it('timing a command witin a fold (3)', function() {
      var html, parts;
      html = strip('<div id="fold-start-after_script" class="fold-start fold">\n  <span class="fold-name">after_script</span>\n  <p>\n    <span id="1-0" class="duration" title="This command finished after 114.31 seconds.">114.31</span>\n    <span id="2-0">timed</span>\n  </p>\n  <p><span id="3-0"></span></p>\n</div>\n<div id="fold-end-after_script" class="fold-end"></div>');
      parts = [[4, 'fold:end:after_script\r'], [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'], [0, 'fold:start:after_script\r'], [2, 'timed\r\n'], [1, 'travis_time:start:1234\r']];
      return expect(this.render(parts)).toBe(html);
    });
  });

}).call(this);
