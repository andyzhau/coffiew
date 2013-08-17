# Coffiew compiler tests.
#
# Author: Andy Zhao(andy@nodeswork.com)

compiler = require 'coffiew/compiler'

describe 'compiler', ->

  describe 'Renderer', ->

    checkTemplate = (tpl, golden) ->
      compiler.compile(tpl)().should.equal golden

    it 'renders simple text', ->
      checkTemplate 'div "#asdf.class1.class2", ->',
        '<div class="class1 class2" id="asdf"></div>'

    it 'renders embedded text', ->
      checkTemplate 'div "#asdf.class1.class2", value: "good", -> div "#another", "content"',
        '<div class="class1 class2" id="asdf" value="good"><div id="another">content</div></div>'
