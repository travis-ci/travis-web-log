describe 'Log', ->
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  # describe 'set', ->
  #   beforeEach ->
  #     @log.set(0, '.')

  #   it 'adds a line', ->
  #     expect(@log.lines.first.id).toBe '0-0'

  #   it 'adds a span to the line', ->
  #     expect(@log.lines.first.children.first.id).toBe '0-0-0'

  # describe 'lines', ->
  #   beforeEach ->
  #     @html = strip '''
  #       <p><span id="0-0-0">foo</span></p>
  #       <p><span id="1-0-0">bar</span></p>
  #       <p><span id="2-0-0">baz</span></p>
  #     '''

  #   it 'ordered', ->
  #     expect(@render [[0, 'foo\n'], [1, 'bar\n'], [2, 'baz\n']]).toBe @html

  #   it 'unordered (1)', ->
  #     expect(@render [[0, 'foo\n'], [2, 'baz\n'], [1, 'bar\n']]).toBe @html

  #   it 'unordered (2)', ->
  #     expect(@render [[1, 'bar\n'], [0, 'foo\n'], [2, 'baz\n']]).toBe @html

  #   it 'unordered (3)', ->
  #     expect(@render [[1, 'bar\n'], [2, 'baz\n'], [0, 'foo\n']]).toBe @html

  #   it 'unordered (4)', ->
  #     expect(@render [[2, 'baz\n'], [0, 'foo\n'], [1, 'bar\n']]).toBe @html

  #   it 'unordered (5)', ->
  #     expect(@render [[2, 'baz\n'], [1, 'bar\n'], [0, 'foo\n']]).toBe @html

  describe 'multiple lines on the same part', ->
    # it 'ordered (1)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="0-1-0">bar</span></p>
    #     <p><span id="0-2-0">baz</span></p>
    #     <p><span id="1-0-0">buz</span></p>
    #     <p><span id="1-1-0">bum</span></p>
    #   '''
    #   expect(@render [[0, 'foo\nbar\nbaz\n'], [1, 'buz\nbum']]).toBe html

    # it 'ordered (2)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="1-0-0">bar</span></p>
    #     <p><span id="1-1-0">baz</span></p>
    #     <p><span id="2-0-0">buz</span></p>
    #     <p><span id="2-1-0">bum</span></p>
    #   '''
    #   expect(@render [[0, 'foo\n'], [1, 'bar\nbaz\n'], [2, 'buz\nbum']]).toBe html

    # it 'ordered (2, chunked)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="0-1-0">bar</span><span id="1-0-0"></span></p>
    #     <p><span id="1-1-0">baz</span></p>
    #     <p><span id="1-2-0">buz</span><span id="2-0-0"></span></p>
    #     <p><span id="2-1-0">bum</span></p>
    #   '''
    #   expect(@render [[0, 'foo\nbar'], [1, '\nbaz\nbuz'], [2, '\nbum']]).toBe html

    # it 'ordered (3, chunked)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
    #     <p><span id="1-1-0">bar</span></p>
    #     <p><span id="1-2-0">baz</span></p>
    #     <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
    #     <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
    #     <p><span id="4-0-0"></span></p>
    #   '''
    #   expect(@render [[0, 'foo'], [1, '\nbar\nbaz\nbuz'], [2, '\nbum'], [3, '\n'], [4, '\n']]).toBe html

    # it 'unordered (1)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="1-0-0">bar</span></p>
    #     <p><span id="1-1-0">baz</span></p>
    #     <p><span id="2-0-0">buz</span></p>
    #     <p><span id="2-1-0">bum</span></p>
    #   '''
    #   expect(@render [[0, 'foo\n'], [2, 'buz\nbum'], [1, 'bar\nbaz\n']]).toBe html

    # it 'unordered (2)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="1-0-0">bar</span></p>
    #     <p><span id="1-1-0">baz</span></p>
    #     <p><span id="2-0-0">buz</span></p>
    #     <p><span id="2-1-0">bum</span></p>
    #   '''
    #   expect(@render [[2, 'buz\nbum'], [0, 'foo\n'], [1, 'bar\nbaz\n']]).toBe html

    # it 'unordered (3)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span></p>
    #     <p><span id="1-0-0">bar</span></p>
    #     <p><span id="1-1-0">baz</span></p>
    #     <p><span id="2-0-0">buz</span></p>
    #     <p><span id="2-1-0">bum</span></p>
    #   '''
    #   expect(@render [[2, 'buz\nbum'], [1, 'bar\nbaz\n'], [0, 'foo\n']]).toBe html

    it 'unordered (4, chunked)', ->
      rescueing @, ->
        html = strip '''
          <p><span id="1-0-0"></span></p>
          <p><span id="1-1-0">foo</span></p>
          <p><span id="2-1-0">bar</span><span id="3-0-0"></span></p>
        '''
        @render [[3, '\n'], [1, '\nfoo'], [2, '\n']]
        dump @log
        # console.log format @render [[3, '\n'], [1, '\nfoo'], [2, '\nbar']]
        # console.log format @render [[1, '\nfoo'], [2, '\nbar'], [3, '\n']]
        # console.log format html

      # html = strip '''
      #   <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
      #   <p><span id="1-1-0">bar</span></p>
      #   <p><span id="1-2-0">baz</span></p>
      #   <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
      #   <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
      #   <p><span id="4-0-0"></span></p>
      # '''
      # console.log format html
      # expect(@render [[3, '\n'], [1, '\nbar\nbaz\nbuz'], [4, '\n'], [2, '\nbum'], [0, 'foo']]).toBe html

    # it 'unordered (5, chunked)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
    #     <p><span id="1-1-0">bar</span></p>
    #     <p><span id="1-2-0">baz</span></p>
    #     <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
    #     <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
    #     <p><span id="4-0-0"></span></p>
    #   '''
    #   expect(@render [[1, '\nbar\nbaz\nbuz'], [0, 'foo'], [3, '\n'], [2, '\nbum'], [4, '\n']]).toBe html

    # it 'unordered (6, chunked)', ->
    #   html = strip '''
    #     <p><span id="0-0-0">foo</span><span id="1-0-0"></span></p>
    #     <p><span id="1-1-0">bar</span></p>
    #     <p><span id="1-2-0">baz</span></p>
    #     <p><span id="1-3-0">buz</span><span id="2-0-0"></span></p>
    #     <p><span id="2-1-0">bum</span><span id="3-0-0"></span></p>
    #     <p><span id="4-0-0"></span></p>
    #   '''
    #   expect(@render [[4, '\n'], [3, '\n'], [2, '\nbum'], [1, '\nbar\nbaz\nbuz'], [0, 'foo']]).toBe html

