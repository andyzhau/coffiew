# Tests for loading coffiew.
#
# Author: Andy Zhao(andy@nodeswork.com)

coffiew = require '.'

describe 'Coffiew', ->

  it 'loads', ->
    coffiew.should.be.ok
    coffiew.config.should.be.ok
    coffiew.compile.should.be.ok
    coffiew.compilePath.should.be.ok
    coffiew.__express.should.be.ok
