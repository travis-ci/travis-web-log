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
        <p><span id="0-0-0">foo</span></p>
        <div id="1-0" class="fold-start fold active"><span class="fold-name">install</span>
          <p><span id="2-0-0">bar</span></p>
          <p><span id="3-0-0">baz</span></p>
          <p><span id="4-0-0">buz</span></p>
        </div>
        <div id="5-0" class="fold-end"></div>
        <p><span id="6-0-0">bum</span></p>
      '''

    it 'ordered', ->
      # expect(@render [[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']]).toBe @html
      rescueing @, ->
        console.log format(@render [[0, 'foo\n'], [1, FOLD_START], [2, 'bar\n'], [3, 'baz\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n']])

  #   it 'unordered (1)', ->
  #     expect(@render [[2, 'bar\n'], [1, FOLD_START], [0, 'foo\n'], [4, 'buz\n'], [6, 'bum\n'], [5, FOLD_END], [3, 'baz\n']]).toBe @html
  #   it 'unordered (2)', ->
  #     expect(@render [[2, 'bar\n'], [4, 'buz\n'], [5, FOLD_END], [6, 'bum\n'], [1, FOLD_START], [0, 'foo\n'], [3, 'baz\n']]).toBe @html
  #   it 'unordered (3)', ->
  #     expect(@render [[6, 'bum\n'], [5, FOLD_END], [4, 'buz\n'], [3, 'baz\n'], [2, 'bar\n'], [1, FOLD_START], [0, 'foo\n']]).toBe @html


  # it 'inserting an unterminated part in front of a fold', ->
  #   parts = [
  #     [2,"travis_fold:start:before_script.1\r$ ./before_script\r\ntravis_fold:end:before_script.1\r"],
  #     [1,"bar"],
  #   ]
  #   html = strip '''
  #     <p><span id="1-0-0">bar</span></p>
  #     <div id="2-0" class="fold-start fold"><span class="fold-name">before_script.1</span>
  #     <p><span id="2-1-0">$ ./before_script</span></p></div>
  #     <div id="2-2" class="fold-end"></div>
  #   '''
  #   expect(@render parts).toBe html

  # it 'inserting a terminated line after a number of unterminated parts within a fold', ->
  #   html = strip '''
  #     <div id="0-0" class="fold-start fold"><span class="fold-name">install</span>
  #       <p><a></a><span id="1-0-0">.</span><span id="2-0-0">end</span></p>
  #     </div>
  #     <div id="3-0" class="fold-end"></div>
  #   '''
  #   rescueing @, ->
  #     expect(@render [[3, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n'], [1, '.'], [2, 'end\n']]).toBe html

  # describe 'an empty fold', ->
  #   it 'does not add "active" as a class', ->
  #     html = strip '''
  #       <div id="0-0" class="fold-start fold"><span class="fold-name">install</span></div>
  #       <div id="1-0" class="fold-end"></div>
  #     '''
  #     rescueing @, ->
  #       console.log format @render [[1, 'travis_fold:end:install\r'], [0, 'travis_fold:start:install\r\n']]

