# Tests configuration.
#
# Author: Andy Zhao(andy@nodeswork.com)

config = require 'coffiew/config'

describe 'Config', ->

  describe 'env', ->

    it 'should run in nodes', ->
      config.env.isNode.should.be.true
