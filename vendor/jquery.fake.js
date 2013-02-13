var $ = {
  fn: {}
}

$.extend = function(one, other) {
  var method, name;
  for (name in other) {
    method = other[name];
    one[name] = method;
  }
  return one;
};

exports.$ = $;
