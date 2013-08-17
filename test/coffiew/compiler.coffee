# Coffiew compiler tests.
#
# Author: Andy Zhao(andy@nodeswork.com)

compiler = require 'coffiew/compiler'
config = require 'coffiew/config'
fs = require 'fs'
path = require 'path'

describe 'compiler', ->

  fixture = rootPath: 'test/files'

  describe 'Renderer', ->

    checkTemplate = (tpl, golden) ->
      compiler.compile(tpl)().should.equal golden

    it 'renders simple text', ->
      checkTemplate 'div "#asdf.class1.class2", ->',
        '<div class="class1 class2" id="asdf"></div>'

    it 'renders embedded text', ->
      checkTemplate 'div "#asdf.class1.class2", value: "good", -> div "#another", "content"',
        '<div class="class1 class2" id="asdf" value="good"><div id="another">content</div></div>'

    it 'compile file path correct', ->
      config.extend prefix: fixture.rootPath + '/'
      files = fs.readdirSync fixture.rootPath
      for file in files
        if path.extname(file) is '.coffiew'
          output = path.join fixture.rootPath, (path.basename file, '.coffiew') + '.html'
          goldenContent = fs.readFileSync output, 'utf8'
          goldenContent = goldenContent.substring 0, goldenContent.length - 1
          compiler.compilePathSync(path.basename file, '.coffiew')().should.eql goldenContent
