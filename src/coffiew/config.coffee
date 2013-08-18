# Configuration of coffiew.
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'

env =
  isBrowser: window?
  isNode: process?
  onError: (path, options, err) ->
    console.error "coffiew renders failed for #{path} with options[#{options}]"
    console.error err.stack
  extension: '.coffiew'
  prefix: ''

module.exports = config =

  env: env

  extend: (configs) -> _.extend env, configs
