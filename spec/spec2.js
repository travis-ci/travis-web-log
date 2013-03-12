(function() {
  var $, ConsoleReporter, beforeEach, describe, document, dump, env, expect, format, it, jasmine, log, render, rescueing, strip, window, _ref;

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

  eval(require('fs').readFileSync('spec/jsdom.js', 'utf-8'));

  document = new exports.Document;

  log = document.createElement('pre');

  log.setAttribute('id', 'log');

  document.appendChild(log);

  require('./../public/js/log.js');

  minispade.require('log');

  strip = function(string) {
    return string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '');
  };

  format = function(html) {
    return html.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div');
  };

  rescueing = function(context, block) {
    var line, _i, _len, _ref1, _results;
    try {
      return block.apply(context);
    } catch (e) {
      _ref1 = e.stack.split("\n");
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        line = _ref1[_i];
        _results.push(console.log(line));
      }
      return _results;
    }
  };

  render = function(context, parts) {
    var num, part, _i, _len, _ref1;
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      _ref1 = parts[_i], num = _ref1[0], part = _ref1[1];
      context.log.set(num, part);
    }
    return strip(document.firstChild.innerHTML);
  };

  dump = function(log) {
    console.log('');
    log.lines.each(function(line) {
      console.log("L." + line.id);
      return line.children.each(function(span) {
        return console.log("  S." + span.id + " " + (span.data.text && JSON.stringify(span.data.text) || '') + (span.ends && ' ends' || ''));
      });
    });
    return console.log('');
  };

  eval(require('fs').readFileSync('./spec/log.js', 'utf-8'));

  env = jasmine.getEnv();

  env.addReporter(new ConsoleReporter(jasmine));

  env.execute();

}).call(this);
