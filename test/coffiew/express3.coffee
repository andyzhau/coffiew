# Coffiew express3 tests.
#
# Author: Andy Zhao(andy@nodeswork.com)

express3 = require 'coffiew/express3'

describe 'Express3', ->

  it 'loads', ->
    express3.should.be.ok
