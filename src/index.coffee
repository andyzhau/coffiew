# Index of coffiew.
# Author: Andy Zhao(andy@nodeswork.com)

config = require './coffiew/config'
compiler = require './coffiew/compiler'
express3 = require './coffiew/express3'

module.exports.config = config
module.exports.compile = compiler.compile
module.exports.compilePath = compiler.compilePath
module.exports.compilePathSync = compiler.compilePathSync
module.exports.__express = express3
