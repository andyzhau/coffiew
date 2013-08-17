# Coffiew compiler.
#
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'
config = require './config'
coffeescript = require 'coffee-script'

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

  isSelfCloseTag: (tagName) -> no

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

# Global functions which template could use
div = () -> __helper.renderTag.apply null, ['div'].concat(Array.prototype.slice.call(arguments))

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
  compile: (template, options={}) ->
    tpl = new Renderer coffeescript.compile(template, bare: yes), options
    (data={}, sections={}) -> tpl.render data, sections

  compilePath: {}
