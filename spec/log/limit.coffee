describe 'Log.Limit', ->
  strip = (string) ->
    string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '')

  format = (html) ->
    html.replace(/<div/gm, '\n<div').replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span')

  rescueing = (context, block) ->
    try
      block.apply(context)
    catch e
      console.log(line) for line in e.stack.split("\n")

  beforeEach ->
    rescueing @, ->
      log.removeChild(log.firstChild) while log.firstChild
      @log = Log.create(engine: Log.Dom, limit: 2)
      @render = (data) ->
        rescueing @, ->
          @log.set(num, string) for [num, string] in data
          strip document.firstChild.innerHTML

  it 'counts the lines', ->
    @render ([num, 'foo\n'] for num in [1..2])
    expect(@log.limit.count).toBe 2

  describe 'separate lines', ->
    beforeEach ->
      @html = @render([num, 'foo\n'] for num in [1..2])

    it 'limits after the given max_lines', ->
      expect(@log.limit.limited).toBe true

    it 'does not limit before the given max_lines', ->
      expect(@html).toMatch /<span id="2-0">/

    it 'limits after the given max_lines', ->
      expect(@html).not.toMatch /<span id="3-0">/

  describe 'joined lines (1)', ->
    beforeEach ->
      @html = @render([[0, 'foo\nbar\n'], [1, 'baz\n']])

    it 'limits after the given max_lines', ->
      expect(@log.limit.limited).toBe true

    it 'does not limit before the given max_lines', ->
      expect(@html).toMatch /<span id="0-1">/

    it 'limits after the given max_lines', ->
      expect(@html).not.toMatch /<span id="1-0">/

  describe 'joined lines (2)', ->
    beforeEach ->
      @html = @render([[0, 'foo\n'], [1, 'bar\nbaz\n']])

    it 'limits after the given max_lines', ->
      expect(@log.limit.limited).toBe true

    it 'does not limit before the given max_lines', ->
      expect(@html).toMatch /<span id="1-0">/

    it 'limits after the given max_lines', ->
      expect(@html).not.toMatch /<span id="1-1">/

  describe 'joined lines (3)', ->
    beforeEach ->
      @html = @render [[0, 'foo\nbar\nbaz\n']]

    it 'limits after the given max_lines', ->
      expect(@log.limit.limited).toBe true

    it 'does not limit before the given max_lines', ->
      expect(@html).toMatch /<span id="0-1">/

    it 'limits after the given max_lines', ->
      expect(@html).not.toMatch /<span id="0-2">/


