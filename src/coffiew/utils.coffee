# Utility functions.
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'
config = require './config'
fs = require 'fs'

module.exports =

  mergeElements: (args...) ->
    _.union _.flatten (arg.split ' ' for arg in args)

  loadTemplateFromPath: (path, cb) ->
    path = "#{config.env.prefix}#{path}.#{config.env.extension}"
    switch
      when config.env.isNode then return fs.readFile path, 'utf8', cb
      when config.env.isBrowser
        requirejs = require 'requirejs'
        requirejs ["text!#{path}"], (templateContent) -> cb null, templateContent
      else cb 'unknown working environment.'

  loadTemplateFromPathSync: (path) ->
    path = "#{config.env.prefix}#{path}.#{config.env.extension}"
    if config.env.isNode
      return fs.readFileSync path, 'utf8'
    throw new Error "Current running environment doesn't support sync mode."
