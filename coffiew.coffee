# Coffee script template engine.
# Author: Andy Zhao(andy@nodeswork.com)

_ = require 'underscore'
changeCase = require 'change-case'
coffeescript = require 'coffee-script'

coffiew ?= {}

###############################################
#
# Configuration
#
###############################################

# Environment and configuration.
coffiew.env = env =

  # Whether on browser
  isBrowser: window?

  # Whether on node.js
  isNode: process?

  # The error callback function.
  onError: (path, options, err) ->
    console.error "coffiew renders failed for #{path} with options[#{options}]"
    console.error err.stack

  # The extension of the template.
  extension: '.coffiew'

  # Prefix to be added to the templates.
  prefix: ''

# Extend configuration.
coffiew.extend = (configs) ->
  _.extend coffiew.env, configs

###############################################
#
# Utils
#
###############################################

coffiew.utils = utils =

  extname: (path) ->
    parts = path.split('.')
    if parts.length? then ".#{parts[parts.length - 1]}" else ''

  join: (args...) ->
    switch args.length
      when 0 then ''
      when 1 then args[0]
      else
        path1 = utils.join.apply null, args.slice 0, args.length - 1
        if path1[path1.length- 1】isnt '/' then path1 += '/'
        path2 = args[args.length - 1]
        if path2[0] isnt '/' then path1 + path2 else path2

  mergeElements: (args...) ->
    _.union _.flatten (arg.split ' ' for arg in args)

  getFullPath: (templatePath) ->
    if utils.extname(templatePath) isnt env.extension
      templatePath += env.extension
    if templatePath[0] isnt '/' then utils.join env.prefix, templatePath
    else templatePath

  loadTemplateFromPath: (path, cb) ->
    path = utils.getFullPath path
    switch
      when env.isNode then require('fs').readFile path, 'utf-8', cb
      when config.env.isBrowser
        requirejs = require 'requirejs'
        requirejs ["text!#{path}"], (templateContent) -> cb null, templateContent
      else cb 'unknown working environment.'

  loadTemplateFromPathSync: (path) ->
    path = utils.getFullPath path
    if env.isNode then return require('fs').readFileSync path, 'utf-8'
    throw new Error "Current running environment doesn't support sync mode."

###############################################
#
# Constants
#
###############################################
coffiew.constants = constants =

  # Values available to the `doctype` function inside a template.
  # Ex.: `doctype 'strict'`
  doctypes:
    default: '<!DOCTYPE html>'
    5: '<!DOCTYPE html>'
    xml: '<?xml version="1.0" encoding="utf-8" ?>'
    transitional: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    strict: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    frameset: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
    1.1: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    basic: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
    mobile: '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
    ce: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

  # Private HTML element reference.
  # Please mind the gap (1 space at the beginning of each subsequent line).
  elements:
    # Valid HTML 5 elements requiring a closing tag.
    # Note: the `var` element is out for obvious reasons, please use `tag 'var'`.
    regular: 'a abbr address article aside audio b bdi bdo blockquote body button
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
 html i iframe ins kbd label legend li main map mark menu meter nav noscript object
 ol optgroup option output p pre progress q rp rt ruby s samp script section
 select small span strong style sub summary sup table tbody td textarea tfoot
 th thead time title tr u ul video'

   # Support for SVG 1.1 tags
    svg: 'a altGlyph altGlyphDef altGlyphItem animate animateColor animateMotion
 animateTransform circle clipPath color-profile cursor defs desc ellipse
 feBlend feColorMatrix feComponentTransfer feComposite feConvolveMatrix
 feDiffuseLighting feDisplacementMap feDistantLight feFlood feFuncA feFuncB
 feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology
 feOffset fePointLight feSpecularLighting feSpotLight feTile feTurbulence
 filter font font-face font-face-format font-face-name font-face-src
 font-face-uri foreignObject g glyph glyphRef hkern image line linearGradient
 marker mask metadata missing-glyph mpath path pattern polygon polyline
 radialGradient rect script set stop style svg symbol text textPath
 title tref tspan use view vkern'

    # Valid self-closing HTML 5 elements.
    void: 'area base br col command embed hr img input keygen link meta param source track wbr'

    # Support for xml sitemap elements
    xml: 'urlset url loc lastmod changefreq priority'

    obsolete: 'applet acronym bgsound dir frameset noframes isindex listing
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol
 nobr spacer tt'

    obsolete_void: 'basefont frame'

###############################################
#
# __helper and Renderer.
#
###############################################
__helper =

  entityMap:
    "&": "&amp;"
    "<": "&lt;"
    ">": "&gt;"
    '"': '&quot;'
    "'": '&#39;'
    "/": '&#x2F;'

  escapeHTML: (content) ->
    content?.toString().replace /[&<>"'\/]/g, (s) -> __helper.entityMap[s]

  closedTags: constants.elements.void.split ' '

  isSelfCloseTag: (tagName) -> tagName in __helper.closedTags

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
      tpl = __helper.compile templateContent, _.extend options, templatePath: path
      if options.cache then __helper.cachedTemplates[path] = tpl
      cb null, tpl

  compilePathSync: (path, options={}) ->
    if options.cache and __helper.cachedTemplates[path]? then return __helper.cachedTemplates[path]
    templateContent = utils.loadTemplateFromPathSync path
    tpl = __helper.compile templateContent, _.extend options, templatePath: path
    if options.cache then __helper.cachedTemplates[path] = tpl
    tpl

  cachedTemplates: {}

# Global functions which template could use
defineCommand = "var #{_.keys(__helper.revTagMap()).join ','};"
if config.env.isNode then require('vm').runInThisContext defineCommand
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
      if config.env.isNode then require('vm').runInThisContext defineCommand
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
    @sections[renderId = @_nextRenderId()] = []
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
    @_text " #{inline}", attrs.safe if inline?.length

    if __helper.isSelfCloseTag tagName
      if contents?
        contents = @_renderContent contents, attrs.safe
        if contents? then @_attrs value: contents
      @_text '>', true
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
        result = contents.call @_currentData()
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
    newData = _.extend {}, @_currentData(), data
    @_text @_loadTpl(partialPath)(newData, @sections), true

  _extend: (path, data={}) ->
    newData = _.extend {}, @_currentData(), data
    @_currentExtend().push => @_loadTpl(path)(newData, @sections)

  _loadTpl: (path) ->
    if config.env.isBrowser
      unless __helper.cachedTemplates[path]?
        # TODO(Andy): throw more descriptive error message.
        throw new Error "#{@options.templatePath} depends on #{path}, which is missing."
      return __helper.cachedTemplates[path]
    if config.env.isNode
      return __helper.compilePathSync path, @options

  _yieldContent: (name, contents) ->
    @_currentSection().push @sections[name] ?= []

  _contentFor: (name, contents) ->
    @sections[renderId = @_nextRenderId()] = []
    @sectionStack.push renderId

    @_renderContent contents
    (@sections[name] ?= []).unshift @sections[renderId]

    delete @sections[renderId]
    @sectionStack.pop()

  _text: (content, safe=false) ->
    @_currentSection().push if safe then content.toString() else __helper.escapeHTML content

  _generateResult: (renderId) ->
    (_.map @_currentExtend(), (extend) -> extend()).join('') +
      _.flatten(@sections[renderId]).join('')

  _currentData: ->
    @dataStack[@dataStack.length - 1]

  _currentSection: ->
    @sections[@sectionStack[@sectionStack.length - 1]]

  _currentExtend: ->
    @extendStack[@extendStack.length - 1]

  _nextRenderId: ->
    "_render#{Renderer._renderId++}"

  _patchData: (data) ->
    _.extend data, env: _.pick(@options, 'templatePath')

###############################################
#
# Exports.
#
###############################################
_.extend module.exports, coffiew
