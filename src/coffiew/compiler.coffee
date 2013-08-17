# Coffiew compiler.
#
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'
changeCase = require 'change-case'
coffeescript = require 'coffee-script'
config = require './config'
constants = require './constants'
utils = require './utils'

__helper =

  entityMap:
    "&": "&amp;"
    "<": "&lt;"
    ">": "&gt;"
    '"': '&quot;'
    "'": '&#39;'
    "/": '&#x2F;'

  escapeHTML: (content) ->
    content.toString().replace /[&<>"'\/]/g, (s) -> __helper.entityMap[s]

  isSelfCloseTag: (tagName) -> tagName in constants.elements.void

  # Seek the renderer instance by looking the caller
  seekRenderer: (args) ->
    caller = args.callee
    caller = caller.caller until caller.renderer?
    caller.renderer

  renderTag: (tagName, args...) ->
    renderer = __helper.seekRenderer arguments
    inline = contents = null; attrs = classes: []
    for arg, i in args
      switch
        when _.isFunction arg then contents = arg
        when _.isObject arg then _.extend attrs, arg
        when _.isString(arg) and args.length is 1 then contents = arg
        when _.isString(arg) and i is 0
          inline = arg.replace /(#|\.)([\w\d-]+)/gi, (match, type, val) ->
            if type is '#' then attrs.id ?= val
            else attrs.classes.push val
            ''
        else contents = arg
    renderer._renderTag tagName, attrs, inline, contents

  allTags: utils.mergeElements.apply null, _.values constants.elements

  revTagMap: _.memoize () ->
    _.object([changeCase.camelCase(tag), tag] for tag in __helper.allTags)

  compile: (templateContent, options={}) ->
    tpl = new Renderer coffeescript.compile(templateContent, bare: yes), options
    (data={}, sections={}) -> tpl.render data, sections

  compilePath: (path, options..., cb) ->
    options = options[0] || {}
    if options.cache and __helper.cachedTemplates[path]?
      return cb null, __helper.cachedTemplates[path]
    utils.loadTemplateFromPath path, (err, templateContent) ->
      if err? then return cb err
      tpl = __helper.compile templateContent, options
      if options.cache then __helper.cachedTemplates[path] = tpl
      cb null, tpl

  compilePathSync: (path, options={}) ->
    if options.cache and __helper.cachedTemplates[path]? then return __helper.cachedTemplates[path]
    templateContent = utils.loadTemplateFromPathSync path
    tpl = __helper.compile templateContent, options
    if options.cache then __helper.cachedTemplates[path] = tpl
    tpl

  cachedTemplates: {}

# Global functions which template could use
defineCommand = "var #{_.keys(__helper.revTagMap()).join ','};"
if config.env.isNode? then require('vm').runInThisContext defineCommand
else eval defineCommand
for camelCaseKey, originKey of __helper.revTagMap()
  eval "#{camelCaseKey} = _.partial(__helper.renderTag, '#{originKey}');"
doctype = (type='default') -> __helper.seekRenderer(arguments)._doctype type
partial = (path, data={}) -> __helper.seekRenderer(arguments)._partial path, data
extend = (path, data={}) -> __helper.seekRenderer(arguments)._extend path, data
yieldContent = (name, contents) -> __helper.seekRenderer(arguments)._yieldContent name, contents
contentFor = (name, contents) -> __helper.seekRenderer(arguments)._contentFor name, contents

class Renderer

  @_renderId: 0

  constructor: (template, @options) ->

    # Define locals
    @locals = _.extend {}, @options.locals
    if _.keys(@locals).length
      defineCommand = "var #{_.keys(@options.locals).join ','};"
      if config.env.isNode? then require('vm').runInThisContext defineCommand
      else eval defineCommand
      for k, v of options
        eval "#{k} = v;"

    # Define template
    eval "this.template = function() {#{template}}"

    # Initialize data stack, section stack and extend stack
    @dataStack = []
    @sectionStack = []
    @extendStack = []

  render: (data, @sections={}) ->
    # Prepare data
    @dataStack.push @_patchData data
    renderId = "_render#{Renderer.renderId++}"
    @sections[renderId] = []
    @sectionStack.push renderId
    @extendStack.push []

    # Render result
    previousRenderer = @template.renderer
    @template.renderer = @
    @template.apply @_currentData(), []  # Render current template
    htmlResult = @_generateResult renderId  # Generate html result to return
    @template.renderer = previousRenderer

    # Clean allocated data
    delete @sections[renderId]
    @dataStack.pop()
    @sectionStack.pop()
    @extendStack.pop()

    # Return result
    htmlResult

  _renderTag: (tagName, attrs, inline, contents) ->
    if tagName is 'text' then return @_renderContent contents, attrs.safe
    @_text "<", true
    @_text "#{tagName}"
    @_attrs attrs
    @_text "#{inline}", attrs.safe if inline?

    if __helper.isSelfCloseTag tagName
      if contents?
        contents = @_renderContent contents, attrs.safe
        if contents? then @_attrs value: contents
      @_text ' />', true
    else
      @_text '>', true
      @_renderContent contents, attrs.safe
      @_text '</', true
      @_text tagName
      @_text '>', true

  _renderContent: (contents, safe=false) ->
    switch
      when _.isFunction contents
        previousRenderer = contents.renderer
        contents.renderer = @
        result = contents.call @data
        if _.isString result
          @_text result, safe
        contents.renderer = previousRenderer
        result
      else
        @_text contents, safe
        contents

  _attrs: (attrs, safe=false) ->
    attrReady = (key, val) =>
      @_text " #{key}=", safe
      @_text '"', true
      @_text val, safe
      @_text '"', true
    for attr, val of attrs
      switch
        when val is true then attrReady attr, attr  # selected="selected"
        when _.isFunction val then attrReady attr, "(#{val}).call(this);"  # bind events.
        # TODO(Andy): supports json data for styles.
        when attr is 'data'
          for k, v of val
            attrReady "data-#{k}", v
        when attr is 'classes'
          if val.length then attrReady 'class', val.join ' '
        when attr is 'safe'
        else attrReady attr, val

  _doctype: (type='default') ->
    @_text constants.doctypes[type], true

  _partial: (path, data={}) ->
    parts = path.split '/'
    parts[parts.length - 1] = '_' + parts[parts.length - 1]
    partialPath = parts.join '/'
    if config.env.isBrowser?
      unless __helper.cachedTemplates[path]?
        # TODO(Andy): throw more descriptive error message.
        throw new Error "#{@options.templatePath} depends on #{path}, which is missing."
      tpl = __helper.cachedTemplates[path]
    if config.env.isNode?
      tpl = __helper.compilePathSync partialPath, @options
    newData = _.extend {}, @_currentData(), data
    @_text tpl.render(newData, @sections), data.safe

  _extend: (path, data={}) ->

  _yieldContent: (name, contents) ->

  _contentFor: (name, contents) ->

  _text: (content, safe=false) ->
    @_currentSection().push if safe then content.toString() else __helper.escapeHTML content

  _generateResult: (renderId) ->
    @extendStack[@extendStack.length - 1].join('') + _.flatten(@sections[renderId]).join('')

  _currentData: ->
    @dataStack[@dataStack.length - 1]

  _currentSection: ->
    @sections[@sectionStack[@sectionStack.length - 1]]

  _patchData: (data) ->
    _.extend data, env: _.pick(@options, 'templatePath')

module.exports =

  compile: __helper.compile

  compilePath: __helper.compilePath
