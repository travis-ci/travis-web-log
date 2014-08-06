describe 'timing', ->
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  it 'timing a command (1)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="0-1">timed</span>
        <span id="0-2"></span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:1234\rtimed\r\ntravis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a command (2)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="0-1">timed</span>
        <span id="1-0"></span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:1234\rtimed\r\n'],
      [1, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a command (3)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">timed</span>
        <span id="2-0"></span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:1234\r'],
      [1, 'timed\r\n' ],
      [2, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a command (4)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="0-1">timed</span>
      </p>
      <p><span id="1-0"></span></p>
    '''
    parts = [
      [1, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [0, 'travis_time:start:1234\rtimed\r\n'],
    ]
    expect(@render parts).toBe html

  it 'timing a command (5)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">timed</span>
      </p>
      <p><span id="2-0"></span></p>
    '''
    parts = [
      [2, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [1, 'timed\r\n' ],
      [0, 'travis_time:start:1234\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a long running command (1)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">one</span>
      </p>
      <p>
        <span id="2-0">two</span>
      </p>
      <p>
        <span id="3-0">three</span>
        <span id="4-0"></span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:1234\r'],
      [1, 'one\r\n' ],
      [2, 'two\r\n' ],
      [3, 'three\r\n' ],
      [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a long running command (2)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">one</span>
      </p>
      <p>
        <span id="2-0">two</span>
      </p>
      <p>
        <span id="3-0">three</span>
      </p>
      <p>
        <span id="4-0"></span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:1234\r'],
      [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [3, 'three\r\n' ],
      [1, 'one\r\n' ],
      [2, 'two\r\n' ],
    ]
    expect(@render parts).toBe html

  it 'timing a long running command (2)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">one</span>
      </p>
      <p>
        <span id="2-0">two</span>
      </p>
      <p>
        <span id="3-0">three</span>
      </p>
      <p>
        <span id="4-0"></span>
      </p>
    '''
    parts = [
      [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [0, 'travis_time:start:1234\r'],
      [2, 'two\r\n' ],
      [3, 'three\r\n' ],
      [1, 'one\r\n' ],
    ]
    expect(@render parts).toBe html

  it 'timing a long running command (3)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
        <span id="1-0">one</span>
      </p>
      <p>
        <span id="2-0">two</span>
      </p>
      <p>
        <span id="3-0">three</span>
      </p>
      <p>
        <span id="4-0"></span>
      </p>
    '''
    parts = [
      [4, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [2, 'two\r\n' ],
      [3, 'three\r\n' ],
      [0, 'travis_time:start:1234\r'],
      [1, 'one\r\n' ],
    ]
    expect(@render parts).toBe html

  it 'timing a command witin a fold (1)', ->
    html = strip '''
      <div id="fold-start-after_script" class="fold-start fold">
        <span class="fold-name">after_script</span>
        <p>
          <span id="0-1" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
          <span id="0-2">timed</span>
          <span id="0-3"></span>
        </p>
      </div>
      <div id="fold-end-after_script" class="fold-end"></div>
      <p><span id="0-5">outside the fold</span></p>
    '''
    parts = [
      [0, 'fold:start:after_script\rtravis_time:start:1234\rtimed\r\ntravis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\rfold:end:after_script\routside the fold\r\n'],
    ]
    expect(@render parts).toBe html

  it 'timing a command within a fold (6, realworld)', ->
    html = strip '''
      <div id="fold-start-git.1" class="fold-start fold">
        <span class="fold-name">git.1</span>
        <p>
          <span id="0-1" class="duration" title="This command finished after 0.42 seconds.">0.42s</span>
          <span id="0-2">e[0K$ git clone</span>
          <span id="0-3"></span>
        </p>
      </div>
      <div id="fold-end-git.1" class="fold-end"></div>
      <p><span id="0-5">e[0K$ cd travis-repos/test-project-1</span></p>
    '''
    parts = [
      [0, 'travis_fold:start:git.1\r\e[0Ktravis_time:start:27547\r\e[0K$ git clone\r\ntravis_time:end:27547:start=1407271442112293793,finish=1407271442529529232,duration=417235439\r\e[0Ktravis_fold:end:git.1\r\e[0K$ cd travis-repos/test-project-1\r\n']
    ]
    expect(@render parts).toBe html

  it 'timing a command witin a fold (1)', ->
    html = strip '''
      <div id="fold-start-after_script" class="fold-start fold">
        <span class="fold-name">after_script</span>
        <p>
          <span id="1-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
          <span id="2-0">timed</span>
          <span id="3-0"></span>
        </p>
      </div>
      <div id="fold-end-after_script" class="fold-end"></div>
    '''
    parts = [
      [0, 'fold:start:after_script\r'],
      [1, 'travis_time:start:1234\r'],
      [2, 'timed\r\n'],
      [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [4, 'fold:end:after_script\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a command witin a fold (2)', ->
    html = strip '''
      <div id="fold-start-after_script" class="fold-start fold active">
        <span class="fold-name">after_script</span>
        <p>
          <span id="1-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
          <span id="2-0">timed</span>
        </p>
        <p><span id="3-0"></span></p>
      </div>
      <div id="fold-end-after_script" class="fold-end"></div>
    '''
    parts = [
      [1, 'travis_time:start:1234\r'],
      [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [2, 'timed\r\n'],
      [0, 'fold:start:after_script\r'],
      [4, 'fold:end:after_script\r'],
    ]
    expect(@render parts).toBe html

  it 'timing a command witin a fold (3)', ->
    html = strip '''
      <div id="fold-start-after_script" class="fold-start fold">
        <span class="fold-name">after_script</span>
        <p>
          <span id="1-0" class="duration" title="This command finished after 0.11 seconds.">0.11s</span>
          <span id="2-0">timed</span>
        </p>
        <p><span id="3-0"></span></p>
      </div>
      <div id="fold-end-after_script" class="fold-end"></div>
    '''
    parts = [
      [4, 'fold:end:after_script\r'],
      [3, 'travis_time:end:1234:start=1407155498890566255,finish=1407155499004871341,duration=114305086\r'],
      [0, 'fold:start:after_script\r'],
      [2, 'timed\r\n'],
      [1, 'travis_time:start:1234\r'],
    ]
    # rescueing @, ->
    #   console.log @render(parts)
    expect(@render parts).toBe html

  it 'timing a command (bug 1)', ->
    html = strip '''
      <p>
        <span id="0-0" class="duration" title="This command finished after 0.23 seconds.">0.23s</span>
        <span id="0-1">$ rvm use default</span>
      </p>
      <p>
        <span id="1-0" class="green">Using /home/travis/.rvm/gems/ruby-1.9.3-p547</span>
        <span id="1-1"></span>
        <span id="2-0"></span>
      </p>
      <p>
        <span id="2-1">$ export BUNDLE_GEMFILE=$PWD/Gemfile</span>
      </p>
    '''
    parts = [
      [0, 'travis_time:start:19130\r\x1b[0K$ rvm use default\r\r\n'],
      [1, '\x1b[32mUsing /home/travis/.rvm/gems/ruby-1.9.3-p547\x1b[0m\r\r\n'],
      [2, 'travis_time:end:19130:start=1407271442547198934,finish=1407271442778174764,duration=230975830\r\x1b[0K$ export BUNDLE_GEMFILE=$PWD/Gemfile\r\r\n']
    ]
    expect(@render parts).toBe html


