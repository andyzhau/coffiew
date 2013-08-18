# Utility functions.
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'
config = require './config'
fs = require 'fs'
path = require 'path'

module.exports = utils =

  mergeElements: (args...) ->
    _.union _.flatten (arg.split ' ' for arg in args)

  getFullPath: (templatePath) ->
    if path.extname(templatePath) isnt config.env.extension
      templatePath += config.env.extension
    if templatePath[0] isnt '/' then path.join config.env.prefix, templatePath
    else templatePath

  loadTemplateFromPath: (path, cb) ->
    path = utils.getFullPath path
    switch
      when config.env.isNode then return fs.readFile path, 'utf-8', cb
      when config.env.isBrowser
        requirejs = require 'requirejs'
        requirejs ["text!#{path}"], (templateContent) -> cb null, templateContent
      else cb 'unknown working environment.'

  loadTemplateFromPathSync: (path) ->
    path = utils.getFullPath path
    if config.env.isNode
      return fs.readFileSync path, 'utf-8'
    throw new Error "Current running environment doesn't support sync mode."
