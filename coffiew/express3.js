// Generated by CoffeeScript 1.6.3
(function() {
  var compiler, config;

  config = require('./config');

  compiler = require('./compiler');

  module.exports = function(path, options, fn) {
    var err, tpl;
    try {
      tpl = compiler.compilePath(path, options);
      return fn(null, tpl(options));
    } catch (_error) {
      err = _error;
      config.onError(path, options, err);
      return fn(err);
    }
  };

}).call(this);
