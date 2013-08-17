# Coffiew utils tests.
#
# Author: Andy Zhao(andy@nodeswork.com)

utils = require 'coffiew/utils'

describe 'Utils', ->

  describe 'mergeElements', ->

    it 'merges correct elements', ->
      utils.mergeElements('a b c d e', 'd e f g h').should.eql(
          ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
