describe 'Log.Dom', ->
  FOLD_START = 'fold:start:install\r\n'
  FOLD_END   = 'fold:end:install\r\n'

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
      @log = Log.create(engine: Log.Dom, listeners: [new Log.FragmentRenderer])
      @render = (data) ->
        rescueing @, ->
          @log.set(num, string) for [num, string] in data
          strip document.firstChild.innerHTML

  describe 'lines', ->
    HTML = strip '''
      <p><span id="0-0-0">foo</span></p>
      <p><span id="1-0-0">bar</span></p>
      <p><span id="2-0-0">baz</span></p>
    '''

    it 'ordered', ->
      expect(@render [[0, 'foo\n'], [1, 'bar\n'], [2, 'baz\n']]).toBe HTML

    it 'unordered (1)', ->
      expect(@render [[0, 'foo\n'], [2, 'baz\n'], [1, 'bar\n']]).toBe HTML

    it 'unordered (2)', ->
      expect(@render [[1, 'bar\n'], [0, 'foo\n'], [2, 'baz\n']]).toBe HTML

    it 'unordered (3)', ->
      expect(@render [[1, 'bar\n'], [2, 'baz\n'], [0, 'foo\n']]).toBe HTML

    it 'unordered (4)', ->
      expect(@render [[2, 'baz\n'], [0, 'foo\n'], [1, 'bar\n']]).toBe HTML

    it 'unordered (5)', ->
      expect(@render [[2, 'baz\n'], [1, 'bar\n'], [0, 'foo\n']]).toBe HTML

  describe 'multiple lines on the same part', ->
    it 'ordered (1)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="0-1-0">bar</span></p>
        <p><span id="0-2-0">baz</span></p>
        <p><span id="1-0-0">buz</span></p>
        <p><span id="1-1-0">bum</span></p>
      '''
      expect(@render [[0, 'foo\nbar\nbaz\n'], [1, 'buz\nbum']]).toBe html

    it 'ordered (2)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">bar</span></p>
        <p><span id="1-1-0">baz</span></p>
        <p><span id="2-0-0">buz</span></p>
        <p><span id="2-1-0">bum</span></p>
      '''
      expect(@render [[0, 'foo\n'], [1, 'bar\nbaz\n'], [2, 'buz\nbum']]).toBe html

    it 'ordered (2, chunked)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="0-1-0">bar</span><span id="1-0-0"></span></p>
        <p><span id="1-1-0">baz</span></p>
        <p><span id="1-2-0">buz</span><span id="2-0-0"></span></p>
        <p><span id="2-1-0">bum</span></p>
      '''
      expect(@render [[0, 'foo\nbar'], [1, '\nbaz\nbuz'], [2, '\nbum']]).toBe html

    it 'ordered (3, chunked)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
        <p><span id="1-1-0">bar</span></p>
        <p><span id="1-2-0">baz</span></p>
        <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
        <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
        <p><span id="4-0-0"></span></p>
      '''
      expect(@render [[0, 'foo'], [1, '\nbar\nbaz\nbuz'], [2, '\nbum'], [3, '\n'], [4, '\n']]).toBe html

    it 'unordered (1)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">bar</span></p>
        <p><span id="1-1-0">baz</span></p>
        <p><span id="2-0-0">buz</span></p>
        <p><span id="2-1-0">bum</span></p>
      '''
      expect(@render [[0, 'foo\n'], [2, 'buz\nbum'], [1, 'bar\nbaz\n']]).toBe html

    it 'unordered (2)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">bar</span></p>
        <p><span id="1-1-0">baz</span></p>
        <p><span id="2-0-0">buz</span></p>
        <p><span id="2-1-0">bum</span></p>
      '''
      expect(@render [[2, 'buz\nbum'], [0, 'foo\n'], [1, 'bar\nbaz\n']]).toBe html

    it 'unordered (3)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">bar</span></p>
        <p><span id="1-1-0">baz</span></p>
        <p><span id="2-0-0">buz</span></p>
        <p><span id="2-1-0">bum</span></p>
      '''
      expect(@render [[2, 'buz\nbum'], [1, 'bar\nbaz\n'], [0, 'foo\n']]).toBe html

    it 'unordered (4, chunked)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
        <p><span id="1-1-0">bar</span></p>
        <p><span id="1-2-0">baz</span></p>
        <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
        <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
        <p><span id="4-0-0"></span></p>
      '''
      expect(@render [[3, '\n'], [1, '\nbar\nbaz\nbuz'], [4, '\n'], [2, '\nbum'], [0, 'foo']]).toBe html

    it 'unordered (5, chunked)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
        <p><span id="1-1-0">bar</span></p>
        <p><span id="1-2-0">baz</span></p>
        <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
        <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
        <p><span id="4-0-0"></span></p>
      '''
      expect(@render [[1, '\nbar\nbaz\nbuz'], [0, 'foo'], [3, '\n'], [2, '\nbum'], [4, '\n']]).toBe html

    it 'unordered (6, chunked)', ->
      html = strip '''
        <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
        <p><span id="1-1-0">bar</span></p>
        <p><span id="1-2-0">baz</span></p>
        <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
        <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
        <p><span id="4-0-0"></span></p>
      '''
      expect(@render [[4, '\n'], [3, '\n'], [2, '\nbum'], [1, '\nbar\nbaz\nbuz'], [0, 'foo']]).toBe html

  describe 'unterminated chunks', ->
    it 'ordered', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[0, '.'], [1, '.'], [2, '.']]).toBe html

    it 'unordered (1)', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[0, '.'], [2, '.'], [1, '.']]).toBe html

    it 'unordered (2)', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[1, '.'], [0, '.'], [2, '.']]).toBe html

    it 'unordered (3)', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[1, '.'], [2, '.'], [0, '.']]).toBe html

    it 'unordered (4)', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[2, '.'], [1, '.'], [0, '.']]).toBe html

    it 'unordered (5)', ->
      html = '<p><span id="0-0-0">.</span><span id="1-0-0">.</span><span id="2-0-0">.</span></p>'
      expect(@render [[2, '.'], [0, '.'], [1, '.']]).toBe html

  describe 'simulating test dot output (10 parts, incomplete permutations)', ->
    it 'ordered', ->
      data = [
        [0, 'foo\n'], [1, 'bar\n'], [2, '.'], [3, '.'], [4, '.\n'],
        [5, 'baz\n'], [6, 'buz\n'], [7, '.'], [8, '.'], [9, '.']
      ]
      html = strip '''
        <p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>
        <p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>
        <p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>
        <p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (1)', ->
      data = [
        [0, 'foo\n'], [2, '.'], [1, 'bar\n'], [4, '.\n'], [3, '.'],
        [6, 'buz\n'], [5, 'baz\n'], [8, '.'], [7, '.'], [9, '.']
      ]
      html = strip '''
        <p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>
        <p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>
        <p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>
        <p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (2)', ->
      data = [
        [0, 'foo\n'], [3, '.'], [1, 'bar\n'], [5, 'baz\n'], [2, '.'],
        [7, '.'], [4, '.\n'], [6, 'buz\n'], [9, '.'], [8, '.']
      ]
      html = strip '''
        <p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>
        <p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>
        <p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>
        <p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (3)', ->
      data = [
        [7, '.'], [9, '.'], [4, '.\n'], [8, '.'], [6, 'buz\n'],
        [2, '.'], [5, 'baz\n'], [0, 'foo\n'], [3, '.'], [1, 'bar\n']
      ]
      html = strip '''
        <p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>
        <p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>
        <p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>
        <p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (4)', ->
      data = [
        [9, '.'], [8, '.'], [7, '.'], [6, 'buz\n'], [5, 'baz\n'],
        [4, '.\n'], [3, '.'], [2, '.'], [1, 'bar\n'], [0, 'foo\n']
      ]
      html = strip '''
        <p><span id="0-0-0">foo</span></p><p><span id="1-0-0">bar</span></p>
        <p><span id="2-0-0">.</span><span id="3-0-0">.</span><span id="4-0-0">.</span></p>
        <p><span id="5-0-0">baz</span></p><p><span id="6-0-0">buz</span></p>
        <p><span id="7-0-0">.</span><span id="8-0-0">.</span><span id="9-0-0">.</span></p>
      '''
      expect(@render data).toBe html

  describe 'simulating test dot output (5 parts, complete permutations)', ->
    beforeEach ->
      @html =
        1: strip '''
          <p><span id="0-0-0">foo</span></p>
          <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
          <p><span id="4-0-0">bar</span></p>
        '''
        2: strip '''
          <p><span id="0-0-0">foo</span></p>
          <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
          <p><span id="4-0-0">bar</span></p>
        '''
        3: strip '''
          <p><span id="0-0-0">foo</span></p>
          <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
          <p><span id="4-0-0">bar</span></p>
        '''

    it 'ordered', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (1)', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (2)', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (3)', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

    it 'unordered (4)', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (4)', ->
      expect(@render [[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.']]).toBe @html[3]


    it 'unordered (5)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (6)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (7)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (8)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

    it 'unordered (9)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (10)', ->
      expect(@render [[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.']]).toBe @html[3]


    it 'unordered (11)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (12)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

    it 'unordered (13)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (14)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

    it 'unordered (15)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (16)', ->
      expect(@render [[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.']]).toBe @html[3]


    it 'unordered (18)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (19)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [2, '.']]).toBe @html[3]

    it 'unordered (20)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (21)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.']]).toBe @html[3]

    it 'unordered (22)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (23)', ->
      expect(@render [[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.']]).toBe @html[3]

    # -----------------------

    it 'unordered (24)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (25)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (26)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (27)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

    it 'unordered (28)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (29)', ->
      expect(@render [[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.']]).toBe @html[3]


    it 'unordered (30)', ->
      expect(@render [[1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (31)', ->
      expect(@render [[1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (32)', ->
      expect(@render [[1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (33)', ->
      expect(@render [[1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[1]

    it 'unordered (34)', ->
      expect(@render [[1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (35)', ->
      expect(@render [[1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]


    it 'unordered (36)', ->
      expect(@render [[1, '.'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (37)', ->
      expect(@render [[1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

    it 'unordered (38)', ->
      expect(@render [[1, '.'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[1]

    it 'unordered (39)', ->
      expect(@render [[1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[1]

    it 'unordered (40)', ->
      expect(@render [[1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']]).toBe @html[1]

    it 'unordered (41)', ->
      expect(@render [[1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']]).toBe @html[1]


    it 'unordered (42)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (43)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

    it 'unordered (44)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (45)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (46)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

    it 'unordered (47)', ->
      expect(@render [[1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

    # -----------------------

    it 'unordered (48)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (49)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (50)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (51)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

    it 'unordered (52)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (53)', ->
      expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]


    it 'unordered (54)', ->
      expect(@render [[2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (55)', ->
      expect(@render [[2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (56)', ->
      expect(@render [[2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (57)', ->
      expect(@render [[2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[2]

    it 'unordered (58)', ->
      expect(@render [[2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (59)', ->
      expect(@render [[2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]


    it 'unordered (60)', ->
      expect(@render [[2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (61)', ->
      expect(@render [[2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

    it 'unordered (62)', ->
      expect(@render [[2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[2]

    it 'unordered (63)', ->
      expect(@render [[2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[2]

    it 'unordered (64)', ->
      expect(@render [[2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']]).toBe @html[2]

    it 'unordered (65)', ->
      expect(@render [[2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']]).toBe @html[2]


    it 'unordered (66)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (67)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.']]).toBe @html[3]

    it 'unordered (68)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (69)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (71)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

    it 'unordered (72)', ->
      expect(@render [[2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n']]).toBe @html[3]

    # -----------------------

    it 'unordered (73)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (74)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

    it 'unordered (75)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (76)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

    it 'unordered (77)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (78)', ->
      expect(@render [[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.']]).toBe @html[3]


    it 'unordered (79)', ->
      expect(@render [[3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (80)', ->
      expect(@render [[3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

    it 'unordered (81)', ->
      expect(@render [[3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (82)', ->
      expect(@render [[3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (83)', ->
      expect(@render [[3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

    it 'unordered (84)', ->
      expect(@render [[3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']]).toBe @html[3]


    it 'unordered (85)', ->
      expect(@render [[3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (86)', ->
      expect(@render [[3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

    it 'unordered (87)', ->
      expect(@render [[3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[3]

    it 'unordered (88)', ->
      expect(@render [[3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (89)', ->
      expect(@render [[3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

    it 'unordered (90)', ->
      expect(@render [[3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']]).toBe @html[3]


    it 'unordered (91)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (92)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.']]).toBe @html[3]

    it 'unordered (92)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

    it 'unordered (93)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (94)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

    it 'unordered (95)', ->
      expect(@render [[3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n']]).toBe @html[3]

    # -----------------------

    it 'unordered (96)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (97)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.']]).toBe @html[3]

    it 'unordered (98)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (99)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.']]).toBe @html[3]

    it 'unordered (100)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (101)', ->
      expect(@render [[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.']]).toBe @html[3]


    it 'unordered (102)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (103)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

    it 'unordered (104)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (105)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (106)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

    it 'unordered (107)', ->
      expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[1]


    it 'unordered (108)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

    it 'unordered (109)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.']]).toBe @html[3]

    it 'unordered (110)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

    it 'unordered (111)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[2]

    it 'unordered (112)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.']]).toBe @html[2]

    it 'unordered (113)', ->
      expect(@render [[4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n']]).toBe @html[2]

    it 'unordered (114)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.']]).toBe @html[3]

    it 'unordered (115)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.']]).toBe @html[3]

    it 'unordered (116)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

    it 'unordered (117)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

    it 'unordered (118)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

    it 'unordered (119)', ->
      expect(@render [[4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n']]).toBe @html[3]


  describe 'folds', ->
    describe 'renders a bunch of lines', ->
      beforeEach ->
        @html = strip '''
          <p><span id="0-0-0">foo</span></p>
          <div id="fold-start-install" class="fold-start"><span class="fold-name">install</span></div>
          <p><span id="2-0-0">bar</span></p>
          <p><span id="3-0-0">baz</span></p>
          <p><span id="4-0-0">buz</span></p>
          <div id="fold-end-install" class="fold-end"></div>
          <p><span id="6-0-0">bum</span></p>
        '''
      it 'ordered', ->
        expect(@render [[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']]).toBe @html
      it 'unordered (1)', ->
        expect(@render [[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']]).toBe @html
      it 'unordered (2)', ->
        expect(@render [[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']]).toBe @html
      it 'unordered (3)', ->
        expect(@render [[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']]).toBe @html

    describe 'with Log.Folds listening', ->
      beforeEach ->
        @log.listeners.push(new Log.Folds)
        @html = strip '''
          <p><span id="0-0-0">foo</span></p>
          <div id="fold-start-install" class="fold-start fold">
            <span class="fold-name">install</span>
            <p><span id="2-0-0">bar</span></p>
            <p><span id="3-0-0">baz</span></p>
            <p><span id="4-0-0">buz</span></p>
          </div>
          <div id="fold-end-install" class="fold-end"></div>
          <p><span id="6-0-0">bum</span></p>
        '''

      it 'ordered', ->
        expect(@render [[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']]).toBe @html
      it 'unordered (1)', ->
        expect(@render [[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']]).toBe @html
      it 'unordered (2)', ->
        expect(@render [[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']]).toBe @html
      it 'unordered (3)', ->
        expect(@render [[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']]).toBe @html


  progress = (total, callback) ->
    total -= 1
    result = []
    step   = Math.ceil(100 / total)
    part   = Math.ceil(total / 100)
    curr   = 1
    ix     = 0
    for count in [1..99] by step
      count = count.toString()
      count = Array(4 - count.length).join(' ') + count
      result.push callback(ix, count, curr, total)
      ix   += 1
      curr += part
      curr = total if curr > total
    result.push callback(ix, 100, total + 1, total + 1)
    result

  describe 'deansi', ->
    it 'simulating git clone', ->
      html = strip '''
        <p><span id="0-0-0">Cloning into 'jsdom'...</span></p>
        <p><span id="1-0-0">remote: Counting objects: 13358, done.</span></p>
        <p style="display: none;"><span id="2-0-0">remote: Compressing objects   1% (1/4)   </span></p>
        <p style="display: none;"><span id="3-0-0">remote: Compressing objects  26% (2/4)   </span></p>
        <p style="display: none;"><span id="4-0-0">remote: Compressing objects  51% (3/4)   </span></p>
        <p style="display: none;"><span id="5-0-0">remote: Compressing objects  76% (4/4)   </span></p>
        <p><span id="6-0-0">remote: Compressing objects 100% (5/5), done.</span></p>
        <p style="display: none;"><span id="7-0-0">Receiving objects   1% (1/4)   </span></p>
        <p style="display: none;"><span id="8-0-0">Receiving objects  26% (2/4)   </span></p>
        <p style="display: none;"><span id="9-0-0">Receiving objects  51% (3/4)   </span></p>
        <p style="display: none;"><span id="10-0-0">Receiving objects  76% (4/4)   </span></p>
        <p><span id="11-0-0">Receiving objects 100% (5/5), done.</span></p>
        <p style="display: none;"><span id="12-0-0">Resolving deltas:   1% (1/4)   </span></p>
        <p style="display: none;"><span id="13-0-0">Resolving deltas:  26% (2/4)   </span></p>
        <p style="display: none;"><span id="14-0-0">Resolving deltas:  51% (3/4)   </span></p>
        <p style="display: none;"><span id="15-0-0">Resolving deltas:  76% (4/4)   </span></p>
        <p><span id="16-0-0">Resolving deltas: 100% (5/5), done.</span></p>
        <p><span id="17-0-0">Something else.</span></p>
      '''

      lines = progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\e[K\n" else "   \e[K\r"
        [ix + 2, "remote: Compressing objects #{count}% (#{curr}/#{total})#{end}"]

      lines = lines.concat progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\n" else "   \r"
        [ix + 7, "Receiving objects #{count}% (#{curr}/#{total})#{end}"]

      lines = lines.concat progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\n" else "   \r"
        [ix + 12, "Resolving deltas: #{count}% (#{curr}/#{total})#{end}"]

      lines = [[0, "Cloning into 'jsdom'...\n"], [1, "remote: Counting objects: 13358, done.\e[K\n"]].concat(lines)
      lines = lines.concat([[17, 'Something else.']])

      expect(@render lines).toBe html

  describe 'random part sizes w/ dot output', ->
    it 'foo', ->
      html = strip '''
        <p>
          <span id="178-0-0" class="green">.</span>
          <span id="179-0-0" class="green">.</span>
          <span id="180-0-0" class="green">.</span>
          <span id="180-0-1" class="yellow">*</span>
          <span id="180-0-2" class="yellow">*</span>
          <span id="181-0-0" class="yellow">*</span>
        </p>
      '''

      parts = [
        [178,"\u001b[32m.\u001b[0m"],
        [179,"\u001b[32m.\u001b[0m"],
        [180,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
        [181,"\u001b[33m*\u001b[0m"],
      ]
      expect(@render parts).toBe html

    # it 'foo', ->
    #  @log.listeners.push(new Log.Folds)

    #   html = strip '''
    #     <p><span id="171-0-0">$ bundle exec rake db:seed RAILS_ENV=test</span></p>
    #     <div id="fold-start-before_script.5" class="fold-start"><span class="fold-name">before_script.5</span></div>
    #     <p><span id="172-1-0">$ sh -e /etc/init.d/xvfb start</span></p>
    #     <p><span id="172-2-0">Starting virtual X frame buffer: Xvfb.</span></p>
    #     <div id="fold-end-before_script.5" class="fold-end"></div>
    #     <p><span id="173-0-0">$ bundle exec rake travis</span></p>
    #     <p>
    #       <span id="178-0-0" class="green">.</span>
    #       <span id="178-0-1" class="green">.</span>
    #       <span id="179-0-0" class="green">.</span>
    #       <span id="179-0-1" class="green">.</span>
    #       <span id="179-0-2" class="green">.</span>
    #     </p>
    #   '''

    #   parts = [
    #     [171,"$ bundle exec rake db:seed RAILS_ENV=test\r\n"],
    #     [172,"travis_fold:start:before_script.5\\r\r\n$ sh -e /etc/init.d/xvfb start\r\nStarting virtual X frame buffer: Xvfb.\r\ntravis_fold:end:before_script.5\\r\r\n"],
    #     [173,"$ bundle exec rake travis\r\n"],
    #     [178,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [179,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [180,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m"],
    #     [181,"\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [182,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [183,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [184,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [185,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [186,"\u001b[32m.\u001b[0m"],
    #     [187,"\u001b[32m.\u001b[0m"],
    #     [188,"\u001b[32m.\u001b[0m"],
    #     [189,"\u001b[32m.\u001b[0m"],
    #     [190,"\u001b[32m.\u001b[0m"],
    #     [191,"\u001b[32m.\u001b[0m"],
    #     [192,"\u001b[32m.\u001b[0m"],
    #     [193,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [194,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [195,"\u001b[32m.\u001b[0m"],
    #     [196,"\u001b[32m.\u001b[0m"],
    #     [197,"\u001b[32m.\u001b[0m"],
    #     [198,"\u001b[32m.\u001b[0m"],
    #     [199,"\u001b[32m.\u001b[0m"],
    #     [200,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [201,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [202,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [203,"\u001b[32m.\u001b[0m"],
    #     [204,"\u001b[32m.\u001b[0m"],
    #     [205,"\u001b[32m.\u001b[0m"],
    #     [206,"\u001b[32m.\u001b[0m"],
    #     [207,"\u001b[32m.\u001b[0m"],
    #     [208,"\u001b[32m.\u001b[0m"],
    #     [219,"\u001b[32m.\u001b[0m"],
    #     [230,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [241,"\u001b[32m.\u001b[0m"],
    #     [252,"\u001b[32m.\u001b[0m"],
    #     [209,"\u001b[32m.\u001b[0m"],
    #     [220,"\u001b[32m.\u001b[0m"],
    #     [231,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [242,"\u001b[32m.\u001b[0m"],
    #     [253,"\u001b[32m.\u001b[0m"],
    #     [210,"\u001b[32m.\u001b[0m"],
    #     [221,"\u001b[32m.\u001b[0m"],
    #     [232,"\u001b[32m.\u001b[0m"],
    #     [243,"\u001b[32m.\u001b[0m"],
    #     [254,"\u001b[32m.\u001b[0m"],
    #     [211,"\u001b[32m.\u001b[0m"],
    #     [222,"\u001b[32m.\u001b[0m"],
    #     [233,"\u001b[32m.\u001b[0m"],
    #     [244,"\u001b[32m.\u001b[0m"],
    #     [255,"\u001b[32m.\u001b[0m"],
    #     [212,"\u001b[32m.\u001b[0m"],
    #     [223,"\u001b[32m.\u001b[0m"],
    #     [234,"\u001b[32m.\u001b[0m"],
    #     [245,"\u001b[32m.\u001b[0m"],
    #     [256,"\u001b[32m.\u001b[0m"],
    #     [213,"\u001b[32m.\u001b[0m"],
    #     [224,"\u001b[32m.\u001b[0m"],
    #     [235,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [246,"\u001b[32m.\u001b[0m"],
    #     [257,"\u001b[32m.\u001b[0m"],
    #     [214,"\u001b[32m.\u001b[0m"],
    #     [225,"\u001b[32m.\u001b[0m"],
    #     [236,"\u001b[32m.\u001b[0m"],
    #     [247,"\u001b[32m.\u001b[0m"],
    #     [258,"\u001b[32m.\u001b[0m"],
    #     [215,"\u001b[32m.\u001b[0m"],
    #     [226,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m"],
    #     [237,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [248,"\u001b[32m.\u001b[0m"],
    #     [259,"\u001b[32m.\u001b[0m"],
    #     [216,"\u001b[32m.\u001b[0m"],
    #     [227,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [238,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [249,"\u001b[32m.\u001b[0m"],
    #     [260,"\u001b[32m.\u001b[0m"],
    #     [217,"\u001b[32m.\u001b[0m"],
    #     [228,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [239,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [250,"\u001b[32m.\u001b[0m"],
    #     [261,"\u001b[32m.\u001b[0m"],
    #     [218,"\u001b[32m.\u001b[0m"],
    #     [229,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [240,"\u001b[32m.\u001b[0m"],
    #     [251,"\u001b[32m.\u001b[0m"],
    #     [262,"\u001b[32m.\u001b[0m"],
    #     [263,"\u001b[32m.\u001b[0m"],
    #     [264,"\u001b[32m.\u001b[0m"],
    #     [265,"\u001b[32m.\u001b[0m"],
    #     [266,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [267,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [268,"\u001b[32m.\u001b[0m"],
    #     [269,"\u001b[32m.\u001b[0m"],
    #     [270,"\u001b[32m.\u001b[0m"],
    #     [271,"\u001b[32m.\u001b[0m"],
    #     [272,"\u001b[32m.\u001b[0m"],
    #     [273,"\u001b[32m.\u001b[0m"],
    #     [274,"\u001b[32m.\u001b[0m"],
    #     [275,"\u001b[32m.\u001b[0m"],
    #     [276,"\u001b[32m.\u001b[0m"],
    #     [277,"\u001b[32m.\u001b[0m"],
    #     [278,"\u001b[32m.\u001b[0m"],
    #     [279,"\u001b[32m.\u001b[0m"],
    #     [280,"\u001b[32m.\u001b[0m"],
    #     [281,"\u001b[32m.\u001b[0m"],
    #     [282,"\u001b[32m.\u001b[0m"],
    #     [283,"\u001b[32m.\u001b[0m"],
    #     [284,"\u001b[32m.\u001b[0m"],
    #     [285,"\u001b[32m.\u001b[0m"],
    #     [286,"\u001b[32m.\u001b[0m"],
    #     [287,"\u001b[32m.\u001b[0m"],
    #     [288,"\u001b[32m.\u001b[0m"],
    #     [289,"\u001b[32m.\u001b[0m"],
    #     [290,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [291,"\u001b[32m.\u001b[0m"],
    #     [292,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [293,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [294,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [295,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [296,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [297,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [298,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [299,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [300,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [301,"\u001b[32m.\u001b[0m"],
    #     [302,"\u001b[32m.\u001b[0m"],
    #     [303,"\u001b[32m.\u001b[0m"],
    #     [304,"\u001b[32m.\u001b[0m"],
    #     [305,"\u001b[32m.\u001b[0m"],
    #     [306,"\u001b[32m.\u001b[0m"],
    #     [307,"\u001b[32m.\u001b[0m"],
    #     [308,"\u001b[32m.\u001b[0m"],
    #     [309,"\u001b[32m.\u001b[0m"],
    #     [310,"\u001b[32m.\u001b[0m"],
    #     [311,"\u001b[32m.\u001b[0m"],
    #     [312,"\u001b[32m.\u001b[0m"],
    #     [313,"\u001b[32m.\u001b[0m"],
    #     [314,"\u001b[32m.\u001b[0m"],
    #     [315,"\u001b[32m.\u001b[0m"],
    #     [316,"\u001b[32m.\u001b[0m"],
    #     [317,"\u001b[32m.\u001b[0m"],
    #     [318,"\u001b[32m.\u001b[0m"],
    #     [319,"\u001b[32m.\u001b[0m"],
    #     [320,"\u001b[32m.\u001b[0m"],
    #     [321,"\u001b[32m.\u001b[0m"],
    #     [322,"\u001b[32m.\u001b[0m"],
    #     [323,"\u001b[32m.\u001b[0m"],
    #     [324,"\u001b[32m.\u001b[0m"],
    #     [325,"\u001b[32m.\u001b[0m"],
    #     [326,"\u001b[32m.\u001b[0m"],
    #     [327,"\u001b[32m.\u001b[0m"],
    #     [328,"\u001b[32m.\u001b[0m"],
    #     [329,"\u001b[32m.\u001b[0m"],
    #     [330,"\u001b[32m.\u001b[0m"],
    #     [331,"\u001b[32m.\u001b[0m"],
    #     [332,"\u001b[32m.\u001b[0m"],
    #     [333,"\u001b[32m.\u001b[0m"],
    #     [334,"\u001b[32m.\u001b[0m"],
    #     [335,"\u001b[32m.\u001b[0m"],
    #     [336,"\u001b[32m.\u001b[0m"],
    #     [337,"\u001b[32m.\u001b[0m"],
    #     [338,"\u001b[32m.\u001b[0m"],
    #     [339,"\u001b[32m.\u001b[0m"],
    #     [340,"\u001b[32m.\u001b[0m"],
    #     [341,"\u001b[32m.\u001b[0m"],
    #     [342,"\u001b[32m.\u001b[0m"],
    #     [343,"\u001b[32m.\u001b[0m"],
    #     [344,"\u001b[32m.\u001b[0m"],
    #     [345,"\u001b[32m.\u001b[0m"],
    #     [346,"\u001b[32m.\u001b[0m"],
    #     [347,"\u001b[32m.\u001b[0m"],
    #     [348,"\u001b[32m.\u001b[0m"],
    #     [349,"\u001b[32m.\u001b[0m"],
    #     [350,"\u001b[32m.\u001b[0m"],
    #     [351,"\u001b[32m.\u001b[0m"],
    #     [352,"\u001b[32m.\u001b[0m"],
    #     [353,"\u001b[32m.\u001b[0m"],
    #     [354,"\u001b[32m.\u001b[0m"],
    #     [355,"\u001b[32m.\u001b[0m"],
    #     [356,"\u001b[32m.\u001b[0m"],
    #     [357,"\u001b[32m.\u001b[0m"],
    #     [358,"\u001b[32m.\u001b[0m"],
    #     [359,"\u001b[32m.\u001b[0m"],
    #     [360,"\u001b[32m.\u001b[0m"],
    #     [361,"\u001b[32m.\u001b[0m"],
    #     [362,"\u001b[32m.\u001b[0m"],
    #     [363,"\u001b[32m.\u001b[0m"],
    #     [364,"\u001b[32m.\u001b[0m"],
    #     [365,"\u001b[32m.\u001b[0m"],
    #     [366,"\u001b[32m.\u001b[0m"],
    #     [367,"\u001b[32m.\u001b[0m"],
    #     [368,"\u001b[32m.\u001b[0m"],
    #     [369,"\u001b[32m.\u001b[0m"],
    #     [370,"\u001b[32m.\u001b[0m"],
    #     [371,"\u001b[32m.\u001b[0m"],
    #     [372,"\u001b[32m.\u001b[0m"],
    #     [373,"\u001b[32m.\u001b[0m"],
    #     [374,"\u001b[32m.\u001b[0m"],
    #     [375,"\u001b[32m.\u001b[0m"],
    #     [376,"\u001b[32m.\u001b[0m"],
    #     [377,"\u001b[32m.\u001b[0m"],
    #     [378,"\u001b[32m.\u001b[0m"],
    #     [379,"\u001b[32m.\u001b[0m"],
    #     [380,"\u001b[32m.\u001b[0m"],
    #     [381,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [382,"\u001b[32m.\u001b[0m"],
    #     [383,"\u001b[32m.\u001b[0m"],
    #     [384,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [385,"\u001b[32m.\u001b[0m"],
    #     [386,"\u001b[32m.\u001b[0m"],
    #     [387,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [388,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [389,"\u001b[32m.\u001b[0m"],
    #     [390,"\u001b[32m.\u001b[0m"],
    #     [391,"\u001b[32m.\u001b[0m"],
    #     [392,"\u001b[32m.\u001b[0m"],
    #     [393,"\u001b[32m.\u001b[0m"],
    #     [394,"\u001b[32m.\u001b[0m"],
    #     [395,"\u001b[32m.\u001b[0m"],
    #     [396,"\u001b[32m.\u001b[0m"],
    #     [397,"\u001b[32m.\u001b[0m"],
    #     [398,"\u001b[32m.\u001b[0m"],
    #     [399,"\u001b[32m.\u001b[0m"],
    #     [400,"\u001b[32m.\u001b[0m"],
    #     [401,"\u001b[32m.\u001b[0m"],
    #     [402,"\u001b[32m.\u001b[0m"],
    #     [403,"\u001b[32m.\u001b[0m"],
    #     [404,"\u001b[32m.\u001b[0m"],
    #     [405,"\u001b[32m.\u001b[0m"],
    #     [406,"\u001b[32m.\u001b[0m"],
    #     [407,"\u001b[32m.\u001b[0m"],
    #     [408,"\u001b[32m.\u001b[0m"],
    #     [409,"\u001b[32m.\u001b[0m"],
    #     [410,"\u001b[32m.\u001b[0m"],
    #     [411,"\u001b[32m.\u001b[0m"],
    #     [412,"\u001b[32m.\u001b[0m"],
    #     [413,"\u001b[32m.\u001b[0m"],
    #     [414,"\u001b[32m.\u001b[0m"],
    #     [415,"\u001b[32m.\u001b[0m"],
    #     [416,"\u001b[32m.\u001b[0m"],
    #     [417,"\u001b[32m.\u001b[0m"],
    #     [418,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [419,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [420,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [421,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [422,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [423,"\u001b[32m.\u001b[0m"],
    #     [424,"\u001b[32m.\u001b[0m"],
    #     [425,"\u001b[32m.\u001b[0m"],
    #     [426,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [427,"\u001b[32m.\u001b[0m"],
    #     [428,"\u001b[32m.\u001b[0m"],
    #     [429,"\u001b[32m.\u001b[0m"],
    #     [430,"\u001b[32m.\u001b[0m"],
    #     [431,"\u001b[32m.\u001b[0m"],
    #     [432,"\u001b[32m.\u001b[0m"],
    #     [433,"\u001b[32m.\u001b[0m"],
    #     [434,"\u001b[32m.\u001b[0m"],
    #     [435,"\u001b[32m.\u001b[0m"],
    #     [436,"\u001b[32m.\u001b[0m"],
    #     [437,"\u001b[32m.\u001b[0m"],
    #     [438,"\u001b[32m.\u001b[0m"],
    #     [439,"\u001b[32m.\u001b[0m"],
    #     [440,"\u001b[32m.\u001b[0m"],
    #     [441,"\u001b[32m.\u001b[0m"],
    #     [442,"\u001b[32m.\u001b[0m"],
    #     [443,"\u001b[32m.\u001b[0m"],
    #     [444,"\u001b[32m.\u001b[0m"],
    #     [445,"\u001b[32m.\u001b[0m"],
    #     [446,"\u001b[32m.\u001b[0m"],
    #     [447,"\u001b[32m.\u001b[0m"],
    #     [448,"\u001b[32m.\u001b[0m"],
    #     [449,"\u001b[32m.\u001b[0m"],
    #     [450,"\u001b[32m.\u001b[0m"],
    #     [451,"\u001b[32m.\u001b[0m"],
    #     [452,"\u001b[32m.\u001b[0m"],
    #     [453,"\u001b[32m.\u001b[0m"],
    #     [454,"\u001b[32m.\u001b[0m"],
    #     [455,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [456,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [457,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [458,"\u001b[32m.\u001b[0m"],
    #     [459,"\u001b[32m.\u001b[0m"],
    #     [460,"\u001b[32m.\u001b[0m"],
    #     [461,"\u001b[32m.\u001b[0m"],
    #     [472,"\u001b[32m.\u001b[0m"],
    #     [462,"\u001b[32m.\u001b[0m"],
    #     [473,"\u001b[32m.\u001b[0m"],
    #     [463,"\u001b[32m.\u001b[0m"],
    #     [474,"\u001b[32m.\u001b[0m"],
    #     [464,"\u001b[32m.\u001b[0m"],
    #     [475,"\u001b[32m.\u001b[0m"],
    #     [465,"\u001b[32m.\u001b[0m"],
    #     [476,"\u001b[32m.\u001b[0m"],
    #     [466,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [477,"\u001b[32m.\u001b[0m"],
    #     [467,"\u001b[32m.\u001b[0m"],
    #     [478,"\u001b[32m.\u001b[0m"],
    #     [468,"\u001b[32m.\u001b[0m"],
    #     [479,"\u001b[32m.\u001b[0m"],
    #     [469,"\u001b[32m.\u001b[0m"],
    #     [470,"\u001b[32m.\u001b[0m"],
    #     [471,"\u001b[32m.\u001b[0m"],
    #     [480,"\u001b[32m.\u001b[0m"],
    #     [481,"\u001b[32m.\u001b[0m"],
    #     [482,"\u001b[32m.\u001b[0m"],
    #     [483,"\u001b[32m.\u001b[0m"],
    #     [484,"\u001b[32m.\u001b[0m"],
    #     [485,"\u001b[32m.\u001b[0m"],
    #     [486,"\u001b[32m.\u001b[0m"],
    #     [487,"\u001b[32m.\u001b[0m"],
    #     [488,"\u001b[32m.\u001b[0m"],
    #     [489,"\u001b[32m.\u001b[0m"],
    #     [490,"\u001b[32m.\u001b[0m"],
    #     [491,"\u001b[32m.\u001b[0m"],
    #     [492,"\u001b[32m.\u001b[0m"],
    #     [493,"\u001b[32m.\u001b[0m"],
    #     [494,"\u001b[32m.\u001b[0m"],
    #     [495,"\u001b[32m.\u001b[0m"],
    #     [496,"\u001b[32m.\u001b[0m"],
    #     [497,"\u001b[32m.\u001b[0m"],
    #     [498,"\u001b[32m.\u001b[0m"],
    #     [499,"\u001b[32m.\u001b[0m"],
    #     [500,"\u001b[32m.\u001b[0m"],
    #     [501,"\u001b[32m.\u001b[0m"],
    #     [502,"\u001b[32m.\u001b[0m"],
    #     [503,"\u001b[32m.\u001b[0m"],
    #     [504,"\u001b[32m.\u001b[0m"],
    #     [505,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m"],
    #     [506,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [507,"\u001b[32m.\u001b[0m"],
    #     [508,"\u001b[32m.\u001b[0m"],
    #     [509,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [510,"\u001b[32m.\u001b[0m"],
    #     [511,"\u001b[32m.\u001b[0m"],
    #     [512,"\u001b[32m.\u001b[0m"],
    #     [513,"\u001b[32m.\u001b[0m"],
    #     [514,"\u001b[32m.\u001b[0m"],
    #     [515,"\u001b[32m.\u001b[0m"],
    #     [516,"\u001b[32m.\u001b[0m"],
    #     [517,"\u001b[32m.\u001b[0m"],
    #     [518,"\u001b[32m.\u001b[0m"],
    #     [519,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [520,"\u001b[32m.\u001b[0m"],
    #     [521,"\u001b[32m.\u001b[0m"],
    #     [522,"\u001b[32m.\u001b[0m"],
    #     [523,"\u001b[32m.\u001b[0m"],
    #     [524,"\u001b[32m.\u001b[0m"],
    #     [525,"\u001b[32m.\u001b[0m"],
    #     [526,"\u001b[32m.\u001b[0m"],
    #     [527,"\u001b[32m.\u001b[0m"],
    #     [528,"\u001b[33m*\u001b[0m"],
    #     [529,"\u001b[32m.\u001b[0m"],
    #     [530,"\u001b[32m.\u001b[0m"],
    #     [531,"\u001b[32m.\u001b[0m"],
    #     [532,"\u001b[32m.\u001b[0m"],
    #     [533,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [534,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [535,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [536,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [537,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [538,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [539,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [540,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [541,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [542,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [543,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [544,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [545,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [546,"\u001b[32m.\u001b[0m"],
    #     [547,"\u001b[32m.\u001b[0m"],
    #     [548,"\u001b[32m.\u001b[0m"],
    #     [549,"\u001b[32m.\u001b[0m"],
    #     [550,"\u001b[32m.\u001b[0m"],
    #     [551,"\u001b[32m.\u001b[0m"],
    #     [552,"\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m\u001b[32m.\u001b[0m"],
    #     [553,"\u001b[32m.\u001b[0m"],
    #     [554,"\u001b[32m.\u001b[0m"],
    #     [555,"\u001b[32m.\u001b[0m"],
    #     [556,"\u001b[32m.\u001b[0m"],
    #     [557,"\u001b[32m.\u001b[0m"],
    #     [558,"\u001b[32m.\u001b[0m"],
    #     [559,"\u001b[32m.\u001b[0m"],
    #     [560,"\u001b[32m.\u001b[0m"],
    #     [561,"\u001b[32m.\u001b[0m"],
    #     [562,"\u001b[32m.\u001b[0m"],
    #     [563,"\u001b[32m.\u001b[0m"],
    #     [564,"\u001b[32m.\u001b[0m"],
    #     [565,"\u001b[32m.\u001b[0m"],
    #     [566,"\u001b[32m.\u001b[0m"],
    #     [567,"\u001b[32m.\u001b[0m"],
    #     [568,"\u001b[33m*\u001b[0m"],
    #     [569,"\u001b[32m.\u001b[0m"],
    #     [570,"\u001b[32m.\u001b[0m"],
    #     [571,"\u001b[32m.\u001b[0m"],
    #     [572,"\u001b[32m.\u001b[0m"],
    #     [573,"\u001b[32m.\u001b[0m"],
    #     [574,"\u001b[32m.\u001b[0m"],
    #     [575,"\u001b[32m.\u001b[0m"],
    #     [576,"\u001b[33m*\u001b[0m"],
    #     [577,"\u001b[33m*\u001b[0m"],
    #     [578,"\u001b[33m*\u001b[0m"],
    #     [579,"\u001b[32m.\u001b[0m"],
    #     [580,"\u001b[32m.\u001b[0m"],
    #     [581,"\u001b[32m.\u001b[0m"],
    #     [582,"\u001b[32m.\u001b[0m"],
    #     [583,"\u001b[32m.\u001b[0m"],
    #     [584,"\u001b[32m.\u001b[0m"],
    #     [585,"\u001b[32m.\u001b[0m"],
    #     [586,"\u001b[32m.\u001b[0m"],
    #     [587,"\u001b[32m.\u001b[0m"],
    #     [588,"\u001b[32m.\u001b[0m"],
    #     [589,"\u001b[32m.\u001b[0m"],
    #     [590,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [591,"\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [592,"\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [593,"\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
    #     [594,"\u001b[32m.\u001b[0m"],
    #     [595,"\u001b[32m.\u001b[0m"],
    #     [596,"\u001b[32m.\u001b[0m"],
    #     [597,"\u001b[32m.\u001b[0m"]
    #   ]
    #   result = @render parts
    #   console.log format result


