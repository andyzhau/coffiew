# Tests for loading coffiew.
#
# Author: Andy Zhao(andy@nodeswork.com)

coffiew = require 'coffiew'
fs = require 'fs'
path = require 'path'

describe 'Coffiew', ->

  it 'loads', ->
    coffiew.should.be.ok
    coffiew.env.should.be.ok
    coffiew.compile.should.be.ok
    coffiew.compilePath.should.be.ok
    coffiew.__express.should.be.ok

  describe 'compiler', ->

    fixture = rootPath: 'test/files'

    describe 'Renderer', ->

      checkTemplate = (tpl, golden) ->
        coffiew.compile(tpl)().should.equal golden

      it 'renders simple text', ->
        checkTemplate 'div "#asdf.class1.class2", ->',
          '<div class="class1 class2" id="asdf"></div>'

      it 'renders embedded text', ->
        checkTemplate 'div "#asdf.class1.class2", value: "good", -> div "#another", "content"',
          '<div class="class1 class2" id="asdf" value="good"><div id="another">content</div></div>'

      it 'compile file path correct', ->
        coffiew.extend prefix: fixture.rootPath + '/'
        files = fs.readdirSync fixture.rootPath
        for file in files
          if path.extname(file) is '.coffiew'
            output = path.join fixture.rootPath, (path.basename file, '.coffiew') + '.html'
            goldenContent = fs.readFileSync output, 'utf8'
            goldenContent = goldenContent.substring 0, goldenContent.length - 1
            coffiew.compilePathSync(path.basename file, '.coffiew')().should.eql goldenContent

  describe 'utils', ->

    it 'merges correct elements', ->
      coffiew.utils.mergeElements('a b c d e', 'd e f g h').should.eql(
          ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
