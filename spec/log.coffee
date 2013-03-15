describe 'Log', ->
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  describe 'set', ->
    beforeEach ->
      @log.set(0, '.')

    it 'adds a part', ->
      expect(@log.children.first.id).toBe '0'

    it 'adds a span to the line', ->
      expect(@log.children.first.children.first.id).toBe '0-0'

  describe 'escaping', ->
    it 'escapes a script tag', ->
      html = strip '''
        <p><span id="0-0">&lt;script&gt;alert("hi!")&lt;/script&gt;</span></p>
      '''
      expect(@render [[0, '<script>alert("hi!")</script>']]).toBe html

  describe 'lines', ->
    beforeEach ->
      @html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="1-0">bar</span></p>
        <p><span id="2-0">baz</span></p>
      '''

    it 'ordered', ->
      rescueing @, ->
        expect(@render [[0, 'foo\n'], [1, 'bar\n'], [2, 'baz\n']]).toBe @html

    it 'unordered (1)', ->
      expect(@render [[0, 'foo\n'], [2, 'baz\n'], [1, 'bar\n']]).toBe @html

    it 'unordered (2)', ->
      expect(@render [[1, 'bar\n'], [0, 'foo\n'], [2, 'baz\n']]).toBe @html

    it 'unordered (3)', ->
      expect(@render [[1, 'bar\n'], [2, 'baz\n'], [0, 'foo\n']]).toBe @html

    it 'unordered (4)', ->
      expect(@render [[2, 'baz\n'], [0, 'foo\n'], [1, 'bar\n']]).toBe @html

    it 'unordered (5)', ->
      expect(@render [[2, 'baz\n'], [1, 'bar\n'], [0, 'foo\n']]).toBe @html

  describe 'multiple lines on the same part', ->
    it 'ordered (1)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="0-1">bar</span></p>
        <p><span id="0-2">baz</span></p>
        <p><span id="1-0">buz</span></p>
        <p><span id="1-1">bum</span></p>
      '''
      expect(@render [[0, 'foo\nbar\nbaz\n'], [1, 'buz\nbum']]).toBe html

    it 'ordered (2)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="1-0">bar</span></p>
        <p><span id="1-1">baz</span></p>
        <p><span id="2-0">buz</span></p>
        <p><span id="2-1">bum</span></p>
      '''
      expect(@render [[0, 'foo\n'], [1, 'bar\nbaz\n'], [2, 'buz\nbum']]).toBe html

    it 'ordered (2, chunked)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="0-1">bar</span><span id="1-0"></span></p>
        <p><span id="1-1">baz</span></p>
        <p><span id="1-2">buz</span><span id="2-0"></span></p>
        <p><span id="2-1">bum</span></p>
      '''
      expect(@render [[0, 'foo\nbar'], [1, '\nbaz\nbuz'], [2, '\nbum']]).toBe html

    it 'ordered (3, chunked)', ->
      html = strip '''
        <p><span id="0-0">foo</span><span id="1-0"></span></p>
        <p><span id="1-1">bar</span></p>
        <p><span id="1-2">baz</span></p>
        <p><span id="1-3">buz</span><span id="2-0"></span></p>
        <p><span id="2-1">bum</span><span id="3-0"></span></p>
        <p><span id="4-0"></span></p>
      '''
      expect(@render [[0, 'foo'], [1, '\nbar\nbaz\nbuz'], [2, '\nbum'], [3, '\n'], [4, '\n']]).toBe html

    it 'unordered (1)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="1-0">bar</span></p>
        <p><span id="1-1">baz</span></p>
        <p><span id="2-0">buz</span></p>
        <p><span id="2-1">bum</span></p>
      '''
      expect(@render [[0, 'foo\n'], [2, 'buz\nbum'], [1, 'bar\nbaz\n']]).toBe html

    it 'unordered (2)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="1-0">bar</span></p>
        <p><span id="1-1">baz</span></p>
        <p><span id="2-0">buz</span></p>
        <p><span id="2-1">bum</span></p>
      '''
      expect(@render [[2, 'buz\nbum'], [0, 'foo\n'], [1, 'bar\nbaz\n']]).toBe html

    it 'unordered (3)', ->
      html = strip '''
        <p><span id="0-0">foo</span></p>
        <p><span id="1-0">bar</span></p>
        <p><span id="1-1">baz</span></p>
        <p><span id="2-0">buz</span></p>
        <p><span id="2-1">bum</span></p>
      '''
      expect(@render [[2, 'buz\nbum'], [1, 'bar\nbaz\n'], [0, 'foo\n']]).toBe html

    it 'unordered (4, chunked)', ->
      html = strip '''
        <p><span id="0-0">foo</span><span id="1-0"></span></p>
        <p><span id="1-1">bar</span></p>
        <p><span id="1-2">baz</span></p>
        <p><span id="1-3">buz</span><span id="2-0"></span></p>
        <p><span id="2-1">bum</span><span id="3-0"></span></p>
        <p><span id="4-0"></span></p>
      '''
      expect(@render [[3, '\n'], [1, '\nbar\nbaz\nbuz'], [4, '\n'], [2, '\nbum'], [0, 'foo']]).toBe html

    it 'unordered (5, chunked)', ->
      html = strip '''
        <p><span id="0-0">foo</span><span id="1-0"></span></p>
        <p><span id="1-1">bar</span></p>
        <p><span id="1-2">baz</span></p>
        <p><span id="1-3">buz</span><span id="2-0"></span></p>
        <p><span id="2-1">bum</span><span id="3-0"></span></p>
        <p><span id="4-0"></span></p>
      '''
      expect(@render [[1, '\nbar\nbaz\nbuz'], [0, 'foo'], [3, '\n'], [2, '\nbum'], [4, '\n']]).toBe html

    it 'unordered (6, chunked)', ->
      html = strip '''
        <p><span id="0-0">foo</span><span id="1-0"></span></p>
        <p><span id="1-1">bar</span></p>
        <p><span id="1-2">baz</span></p>
        <p><span id="1-3">buz</span><span id="2-0"></span></p>
        <p><span id="2-1">bum</span><span id="3-0"></span></p>
        <p><span id="4-0"></span></p>
      '''
      expect(@render [[4, '\n'], [3, '\n'], [2, '\nbum'], [1, '\nbar\nbaz\nbuz'], [0, 'foo']]).toBe html

  describe 'unterminated chunks', ->
    it 'ordered', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[0, '.'], [1, '.'], [2, '.']]).toBe html

    it 'unordered (1)', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[0, '.'], [2, '.'], [1, '.']]).toBe html

    it 'unordered (2)', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[1, '.'], [0, '.'], [2, '.']]).toBe html

    it 'unordered (3)', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[1, '.'], [2, '.'], [0, '.']]).toBe html

    it 'unordered (4)', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[2, '.'], [1, '.'], [0, '.']]).toBe html

    it 'unordered (5)', ->
      html = '<p><span id="0-0">.</span><span id="1-0">.</span><span id="2-0">.</span></p>'
      expect(@render [[2, '.'], [0, '.'], [1, '.']]).toBe html

  describe 'simulating test dot output (10 parts, incomplete permutations)', ->
    it 'ordered', ->
      data = [
        [0, 'foo\n'], [1, 'bar\n'], [2, '.'], [3, '.'], [4, '.\n'],
        [5, 'baz\n'], [6, 'buz\n'], [7, '.'], [8, '.'], [9, '.']
      ]
      html = strip '''
        <p><span id="0-0">foo</span></p><p><span id="1-0">bar</span></p>
        <p><span id="2-0">.</span><span id="3-0">.</span><span id="4-0">.</span></p>
        <p><span id="5-0">baz</span></p><p><span id="6-0">buz</span></p>
        <p><span id="7-0">.</span><span id="8-0">.</span><span id="9-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (1)', ->
      data = [
        [0, 'foo\n'], [2, '.'], [1, 'bar\n'], [4, '.\n'], [3, '.'],
        [6, 'buz\n'], [5, 'baz\n'], [8, '.'], [7, '.'], [9, '.']
      ]
      html = strip '''
        <p><span id="0-0">foo</span></p><p><span id="1-0">bar</span></p>
        <p><span id="2-0">.</span><span id="3-0">.</span><span id="4-0">.</span></p>
        <p><span id="5-0">baz</span></p><p><span id="6-0">buz</span></p>
        <p><span id="7-0">.</span><span id="8-0">.</span><span id="9-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (2)', ->
      data = [
        [0, 'foo\n'], [3, '.'], [1, 'bar\n'], [5, 'baz\n'], [2, '.'],
        [7, '.'], [4, '.\n'], [6, 'buz\n'], [9, '.'], [8, '.']
      ]
      html = strip '''
        <p><span id="0-0">foo</span></p><p><span id="1-0">bar</span></p>
        <p><span id="2-0">.</span><span id="3-0">.</span><span id="4-0">.</span></p>
        <p><span id="5-0">baz</span></p><p><span id="6-0">buz</span></p>
        <p><span id="7-0">.</span><span id="8-0">.</span><span id="9-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (3)', ->
      data = [
        [7, '.'], [9, '.'], [4, '.\n'], [8, '.'], [6, 'buz\n'],
        [2, '.'], [5, 'baz\n'], [0, 'foo\n'], [3, '.'], [1, 'bar\n']
      ]
      html = strip '''
        <p><span id="0-0">foo</span></p><p><span id="1-0">bar</span></p>
        <p><span id="2-0">.</span><span id="3-0">.</span><span id="4-0">.</span></p>
        <p><span id="5-0">baz</span></p><p><span id="6-0">buz</span></p>
        <p><span id="7-0">.</span><span id="8-0">.</span><span id="9-0">.</span></p>
      '''
      expect(@render data).toBe html

    it 'unordered (4)', ->
      data = [
        [9, '.'], [8, '.'], [7, '.'], [6, 'buz\n'], [5, 'baz\n'],
        [4, '.\n'], [3, '.'], [2, '.'], [1, 'bar\n'], [0, 'foo\n']
      ]
      html = strip '''
        <p><span id="0-0">foo</span></p><p><span id="1-0">bar</span></p>
        <p><span id="2-0">.</span><span id="3-0">.</span><span id="4-0">.</span></p>
        <p><span id="5-0">baz</span></p><p><span id="6-0">buz</span></p>
        <p><span id="7-0">.</span><span id="8-0">.</span><span id="9-0">.</span></p>
      '''
      expect(@render data).toBe html

  it 'inserting a terminated line after a number of unterminated parts', ->
    html = strip '''
      <p><span id="1-0">.</span><span id="2-0">end</span></p>
      <p><span id="3-0">end</span></p>
      <p><span id="4-0">.</span><span id="5-0">.</span><span id="6-0">.</span><span id="7-0">end</span></p>
    '''
    expect(@render [[5,'.'], [4,'.'], [1,'.'], [2,'end\n'], [3,'end\n'], [6,'.'], [7,'end\n']]).toBe html

