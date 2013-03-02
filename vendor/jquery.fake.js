var $ = {
  fn: {}
}

$.extend = function(one, other) {
  var method, name;
  for (name in other) {
    one[name] = other[name];
  }
  return one;
};

exports.$ = $;
exports.document = { createDocumentFragment: function() {}, createElement: function() {} }
exports.window = { execScript: function(script) { eval(script) } }

