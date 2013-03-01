(function() {
  var $, ConsoleReporter, beforeEach, describe, document, env, expect, it, jasmine, window, _ref;

  $ = require('./../vendor/jquery.fake.js').$;

  _ref = require('./../vendor/jasmine.js'), jasmine = _ref.jasmine, describe = _ref.describe, beforeEach = _ref.beforeEach, it = _ref.it, expect = _ref.expect;

  ConsoleReporter = require('./../vendor/jasmine.reporter.js').ConsoleReporter;

  document = {
    createDocumentFragment: (function() {}),
    createElement: (function() {})
  };

  window = {
    execScript: function(script) {
      return eval(script);
    }
  };

  eval(require('fs').readFileSync('vendor/minispade.js', 'utf-8'));

  eval(require('fs').readFileSync('vendor/ansiparse.js', 'utf-8'));

  require('./../public/js/log.js');

  minispade.require('log');

  eval(require('fs').readFileSync('./spec/engine/chunks.js', 'utf-8'));

  env = jasmine.getEnv();

  env.addReporter(new ConsoleReporter(jasmine));

  env.execute();

}).call(this);
