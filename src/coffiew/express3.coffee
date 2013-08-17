# Coffiew express3 adapter.
#
# Author: Andy Zhao(andy@nodeswork.com)

config = require './config'
compiler = require './compiler'

module.exports = (path, options, fn) ->
  try
    tpl = compiler.compilePath path, options
    fn null, tpl options
  catch err
    config.onError path, options, err
    fn err
