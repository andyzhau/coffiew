# Utility functions.
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'

module.exports =

  mergeElements: (args...) ->
    _.union _.flatten (arg.split ' ' for arg in args)
