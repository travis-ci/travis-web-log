describe 'folds', ->
  FOLD_START = 'fold:start:install\r\n'
  FOLD_END   = 'fold:end:install\r\n'

  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  describe 'renders a bunch of lines', ->
    beforeEach ->
      @html = strip '''
        <p><span id="0-0">foo</span></p>
        <div id="fold-start-install" class="fold-start fold active"><span class="fold-name">install</span>
          <p><span id="2-0">bar</span></p>
          <p><span id="3-0">baz</span></p>
          <p><span id="4-0">buz</span></p>
        </div>
        <div id="fold-end-install" class="fold-end"></div>
        <p><span id="6-0">bum</span></p>
      '''

    it 'ordered', ->
      expect(@render [[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']]).toBe @html
    it 'unordered (1)', ->
      expect(@render [[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']]).toBe @html
    it 'unordered (2)', ->
      expect(@render [[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']]).toBe @html
    it 'unordered (3)', ->
      expect(@render [[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']]).toBe @html

  it 'inserting an unterminated part in front of a fold', ->
    parts = [
      [2,"travis_fold:start:install\r$ ./install\r\ntravis_fold:end:install\r"],
      [1,"bar"],
    ]
    html = strip '''
      <p><span id="1-0">bar</span></p>
      <div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span>
      <p><span id="2-1">$ ./install</span></p></div>
      <div id="fold-end-install" class="fold-end"></div>
    '''
    expect(@render parts).toBe html

  it 'inserting a terminated line after a number of unterminated parts within a fold', ->
    html = strip '''
      <div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span>
        <p><a></a><span id="1-0">.</span><span id="2-0">end</span></p>
      </div>
      <div id="fold-end-install" class="fold-end"></div>
    '''
    expect(@render [[3, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n'], [1, '.'], [2, 'end\n']]).toBe html

  it 'an empty fold', ->
    html = strip '''
      <div id="fold-start-install" class="fold-start fold"><span class="fold-name">install</span></div>
      <div id="fold-end-install" class="fold-end"></div>
    '''
    expect(@render [[1, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n']]).toBe html

  it 'inserting a fold after a span that will be split out later', ->
    html = strip '''
      <p><span id="1-0">first</span></p>
      <p><span id="2-0">.</span></p>
      <div id="fold-start-after_script" class="fold-start fold"><span class="fold-name">after_script</span>
        <p><span id="3-1">folded</span></p>
      </div>
      <div id="fold-end-after_script" class="fold-end"></div>
      <p><span id="4-0">last</span></p>
    '''
    parts = [
      [2,'.'],
      [4,'last\n'],
      [3,'fold:start:after_script\rfolded\r\nfold:end:after_script\r'],
      [1,'first\n'],
    ]
    expect(@render parts).toBe html


