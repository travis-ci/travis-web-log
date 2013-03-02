# Listener = ->
# $.extend Listener.prototype,
#   notify: ->
#     console.log(Array.prototype.slice.apply(arguments).slice(1))

describe 'Log.Chunks', ->
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log(Log.Chunks)
    @log.listeners.push new Log.FragmentRenderer

  html = ->
    document.firstChild.innerHTML

  rescueing = (context, block) ->
    try
      block.apply(context)
    catch e
      console.log(line) for line in e.stack.split("\n")

  describe 'set', ->
    it 'renders an unterminated chunk', ->
      @log.set 0, 'foo'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
      '''

    it 'renders a bunch of unterminated chunks', ->
      @log.set 0, '.'
      @log.set 1, '.'
      @log.set 2, '.'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>
      '''

    it 'renders a bunch of unordered, unterminated chunks (1)', ->
      @log.set 2, '.'
      @log.set 0, '.'
      @log.set 1, '.'
      expect(html()).toBe '''
        <p id="2-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>
      '''

    it 'renders a bunch of unordered, unterminated chunks (2)', ->
      @log.set 1, '.'
      @log.set 0, '.'
      @log.set 2, '.'
      expect(html()).toBe '''
        <p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>
      '''

    it 'renders a bunch of unordered, unterminated chunks (3)', ->
      @log.set 1, '.'
      @log.set 2, '.'
      @log.set 0, '.'
      expect(html()).toBe '''
        <p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>
      '''

    it 'renders a bunch of lines', ->
      @log.set 0, 'foo\n'
      @log.set 1, 'bar\n'
      @log.set 2, 'baz\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="1-0"><a></a><span id="1-0-0">bar</span></p>
        <p id="2-0"><a></a><span id="2-0-0">baz</span></p>
      '''.replace(/\n/g, '')

    it 'renders a bunch of unordered lines (1)', ->
      @log.set 0, 'foo\n'
      @log.set 1, 'bar\n'
      @log.set 2, 'baz\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="1-0"><a></a><span id="1-0-0">bar</span></p>
        <p id="2-0"><a></a><span id="2-0-0">baz</span></p>
      '''.replace(/\n/g, '')

    it 'renders a bunch of unordered lines (2)', ->
      @log.set 1, 'bar\n'
      @log.set 0, 'foo\n'
      @log.set 2, 'baz\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="1-0"><a></a><span id="1-0-0">bar</span></p>
        <p id="2-0"><a></a><span id="2-0-0">baz</span></p>
      '''.replace(/\n/g, '')

    it 'renders a bunch of unordered lines (3)', ->
      @log.set 2, 'baz\n'
      @log.set 0, 'foo\n'
      @log.set 1, 'bar\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="1-0"><a></a><span id="1-0-0">bar</span></p>
        <p id="2-0"><a></a><span id="2-0-0">baz</span></p>
      '''.replace(/\n/g, '')

    it 'simulating test dot output', ->
      @log.set 0, 'foo\n'
      @log.set 1, '.'
      @log.set 2, '.'
      @log.set 3, '.\n'
      @log.set 4, 'bar\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p id="4-0"><a></a><span id="4-0-0">bar</span></p>
      '''.replace(/\n/g, '')

    it 'terminator out of order', ->
      @log.set 0, '.'
      @log.set 2, 'bar\n'
      @log.set 1, '.\n'
      expect(html()).toBe '''
        <p id="1-0"><a></a><span id="0-0-0">.</span><span id="1-0-0">.</span></p>
        <p id="2-0"><a></a><span id="2-0-0">bar</span></p>
      '''.replace(/\n/g, '')

    it 'simulating unordered test dot output (1)', ->
      @log.set 0, 'foo\n'
      @log.set 3, '.\n'
      @log.set 1, '.'
      @log.set 2, '.'
      @log.set 4, 'bar\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p id="4-0"><a></a><span id="4-0-0">bar</span></p>
      '''.replace(/\n/g, '')

    it 'simulating unordered test dot output (2)', ->
      @log.set 4, 'bar\n'
      @log.set 1, '.'
      @log.set 0, 'foo\n'
      @log.set 3, '.\n'
      @log.set 2, '.'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p id="4-0"><a></a><span id="4-0-0">bar</span></p>
      '''.replace(/\n/g, '')

    it 'simulating unordered test dot output (3)', ->
      @log.set 4, 'bar\n'
      @log.set 3, '.\n'
      @log.set 1, '.'
      @log.set 2, '.'
      @log.set 0, 'foo\n'
      expect(html()).toBe '''
        <p id="0-0"><a></a><span id="0-0-0">foo</span></p>
        <p id="3-0"><a></a><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p id="4-0"><a></a><span id="4-0-0">bar</span></p>
      '''.replace(/\n/g, '')
