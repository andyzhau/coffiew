# Index of coffiew.
# Author: Andy Zhao(andy@nodeswork.com)

requirejs = require './modules/requirejs'

requirejs ['./coffiew/compiler', './coffiew/express3'], (compiler, express3) ->
  compile: compiler.compile
  compilePath: compiler.compilePath
  __express: express3
