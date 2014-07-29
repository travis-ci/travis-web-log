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
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  format = (html) ->
    html.replace(/<p><span/gm, '<p>\n  <span')
        .replace(/<div/gm, '\n<div')
        .replace(/<p>/gm, '\n<p>')
        .replace(/<\/p>/gm, '\n</p>')

  describe 'carriage returns and newlines', ->
    it 'nl', ->
      html = @render [[0, 'foo\n']]
      expect(html).toBe '<p><span id="0-0">foo</span></p>'

    it 'cr nl', ->
      html = @render [[0, 'foo\r\n']]
      expect(html).toBe '<p><span id="0-0">foo</span></p>'

    it 'cr cr nl', ->
      html = @render [[0, 'foo\r\r\n']]
      expect(html).toBe '<p><span id="0-0">foo</span></p>'

    it 'cr', ->
      html = @render [[0, 'foo\r']]
      expect(html).toBe '<p><span id="0-0" class="clears"></span></p>'

    it 'cr clear line', ->
      html = @render [[0, 'foo\r\x1b[0K']]
      expect(html).toBe '<p><span id="0-0" class="clears"></span></p>'


  it 'clear line works', ->
    html = @render [[0, '\x1b[0m\x1b[1000D\x1b[?25l\x1b[32m  5%\x1b[0m\x1b[1000D\x1b[?25l\x1b[32m 11%']]
    expect(html).toBe '<p><span id="0-2" class="clears"></span><span id="0-3" class="green"> 11%</span></p>'

  it 'can cope with hide/show cursor', ->
    html = @render [[0, 'foo\x1b[?25h\n\x1b[1000D\x1b[K\n']]
    expect(html).toBe strip '''
      <p><span id="0-0">foo</span></p>
      <p><span id="0-1" class="clears"></span><span id="0-2"></span></p>
    '''

  it 'removes spans before a clearing span', ->
    html = strip '''
      <p><span id="0-0">foo</span></p>
      <p><span id="3-0" class="clears"></span><span id="4-0">bam</span></p>
    '''
    expect(@render [[0, 'foo\nbar'], [1, 'baz'], [4, 'bam'], [3, 'bum\r'], [2, 'buz']]).toBe html

  describe 'progress (1)', ->
    beforeEach ->
      @html = strip '''
        <p>
          <span id="2-0" class="clears"></span>
          <span id="2-1">Done.</span>
        </p>
      '''

    it 'clears the line if the carriage return sits on the next part (ordered)', ->
      expect(@render [[0, '0%\r1%'], [1, '\r2%\r'], [2, '\rDone.']]).toBe @html

    it 'clears the line if the carriage return sits on the next part (unordered, 1)', ->
      expect(@render [[1, '\r2%\r'], [2, '\rDone.'], [0, '0%\r1%']]).toBe @html

    it 'clears the line if the carriage return sits on the next part (unordered, 3)', ->
      expect(@render [[2, '\rDone.'], [1, '\r2%\r'], [0, '0%\r1%']]).toBe @html

  describe 'progress (2)', ->
    beforeEach ->
      @html = strip '''
        <p>
          <span id="0-0">foo</span>
          <span id="1-0"></span>
        </p>
        <p>
          <span id="4-0" class="clears"></span>
          <span id="4-1">3%</span>
        </p>
      '''

    it 'ordered', ->
      expect(@render [[0,'foo'], [1,'\n'], [2,'\r1%'], [3,'\r2%'], [4,'\r3%']]).toBe @html

    it 'unordered (1)', ->
      expect(@render [[0,'foo'], [2,'\r1%'], [1,'\n'], [4,'\r3%'], [3,'\r2%']]).toBe @html

    it 'unordered (2)', ->
      expect(@render [[1,'\n'], [3,'\r2%'], [2,'\r1%'], [0,'foo'], [4,'\r3%']]).toBe @html

    it 'unordered (3)', ->
      expect(@render [[4,'\r3%'], [3,'\r2%'], [2,'\r1%'], [0,'foo'], [1,'\n']]).toBe @html


  it 'progress (2)', ->
      log = 'Started\r\n\r\n\x1b[1000D\x1b[?25l\x1b[32m1/36: [= ] 50% 00:00:00\x1b[0m\x1b[1000D\x1b[?25l\x1b[32m36/36: [==] 9.0/s 100% 00:00:04\x1b[0m\x1b[1000D\x1b[?25l\x1b[32m36/36: [==] 9.0/s 100% 00:00:04\x1b[0m\x1b[?25h\r\n\x1b[0m\x1b[1000D\x1b[K\r\nFinished in 4.76991s\r\n'
      html = strip '''
        <p><span id="0-0">Started</span></p>
        <p><span id="0-1"></span></p>
        <p><span id="0-6" class="clears"></span><span id="0-7" class="green">36/36: [==] 9.0/s 100% 00:00:04</span><span id="0-8"></span></p>
        <p><span id="0-9" class="clears"></span><span id="0-10"></span></p>
        <p><span id="0-11">Finished in 4.76991s</span></p>
      '''
      expect(@render [[0, log]]).toBe html

  it 'simulating git clone', ->
    rescueing @, ->
      html = strip '''
        <p><span id="0-0">Cloning into 'jsdom'...</span></p>
        <p><span id="1-0">remote: Counting objects: 13358, done.</span></p>
        <p>
          <span id="5-0" class="clears"></span>
          <span id="6-0">remote: Compressing objects 100% (5/5), done.</span></p>
        <p>
          <span id="10-0" class="clears"></span>
          <span id="11-0">Receiving objects 100% (5/5), done.</span></p>
        <p>
          <span id="15-0" class="clears"></span>
          <span id="16-0">Resolving deltas: 100% (5/5), done.</span>
        </p>
        <p><span id="17-0">Something else.</span></p>
      '''

      lines = progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\x1b[K\n" else "   \x1b[K\r"
        [ix + 2, "remote: Compressing objects #{count}% (#{curr}/#{total})#{end}"]

      lines = lines.concat progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\n" else "   \r"
        [ix + 7, "Receiving objects #{count}% (#{curr}/#{total})#{end}"]

      lines = lines.concat progress 5, (ix, count, curr, total) ->
        end = if count == 100 then ", done.\n" else "   \r"
        [ix + 12, "Resolving deltas: #{count}% (#{curr}/#{total})#{end}"]

      lines = [[0, "Cloning into 'jsdom'...\n"], [1, "remote: Counting objects: 13358, done.\x1b[K\n"]].concat(lines)
      lines = lines.concat([[17, 'Something else.']])

      expect(@render lines).toBe html

  it 'random part sizes w/ dot output', ->
    html = strip '''
      <p>
        <span id="1-0" class="green bold">.</span>
      </p>
    '''

    parts = [
      [1, "\u001b[32m\u001b[0;1m.\u001b[0;0m\u001b[0m"],
    ]
    expect(@render parts).toBe html

  it 'properly sets multipla classes', ->
    html = strip '''
      <p>
        <span id="1-0" class="green">.</span>
        <span id="2-0" class="green">.</span>
        <span id="3-0" class="green">.</span>
        <span id="3-1" class="yellow">*</span>
        <span id="3-2" class="yellow">*</span>
        <span id="4-0" class="yellow">*</span>
      </p>
    '''

    parts = [
      [1,"\u001b[32m.\u001b[0m"],
      [2,"\u001b[32m.\u001b[0m"],
      [3,"\u001b[32m.\u001b[0m\u001b[33m*\u001b[0m\u001b[33m*\u001b[0m"],
      [4,"\u001b[33m*\u001b[0m"],
    ]
    expect(@render parts).toBe html

  it 'wild thing with a fold and <cr>s at the beginning of the line', ->
    html = strip '''
      <p><span id="2-0" class="clears"></span><span id="2-1">foo.2</span></p>
      <p><span id="3-0" class="clears"></span><span id="3-1">bar.3</span></p>
      <div id="fold-start-install" class="fold-start"><span class="fold-name">install</span></div>
      <p><span id="5-0" class="clears"></span></p>
    '''
    parts = [
      [1, 'foo.1'],
      [2, '\rfoo.2\r\n'],
      [3, 'bar.2\rbar.3\r\n'],
      [4, 'travis_fold:start:install\r'],
      [5, '\r']
    ]
    expect(@render parts).toBe html

  it 'wild thing with ansi parts preceeding a <cr> inserted late', ->
    html = strip '''
      <p><span id="0-0">foo</span><span id="0-1">bar</span></p>
      <p><span id="1-0" class="clears"></span><span id="1-1">baz</span></p>
    '''
    parts = [
      [1, '\rbaz\r\n'],
      [0, '\u001b[0mfoo\u001b[0mbar\r\n\r']
    ]
    expect(@render parts).toBe html

  it 'clears a span when inserted late on a part that has a newline', ->
    html = strip '''
      <p>
        <span id="1-0">foo</span>
      </p>
      <p>
        <span id="2-0" class="clears"></span><span id="2-1">baz</span>
      </p>
    '''
    parts = [
      [2,"\rbaz"],
      [1,"foo\nbar"],
    ]
    expect(@render parts).toBe html

  it 'renders unescaped "eM" correctly', ->
    html = strip '''
      <p>
        <span id="0-0">coreMath</span>
      </p>
    '''
    parts = [
      [0, "coreMath"]
    ]
    expect(@render parts).toBe html

  describe 'travis_time and travis_fold', ->
    it 'works (1)', ->
      html = strip '''
        <div id="fold-start-git.1" class="fold-start fold active">
          <span class="fold-name">git.1</span>
          <p>
            <span id="0-1" class="clears"></span>
            <span id="0-2">$ git clone git://github.com/travis-repos/test-project-1.git</span>
          </p>
          <p>
            <span id="1-0">Cloning into "travis-repos/test-project-1"...</span>
          </p>
          <p>
            <span id="2-0" class="clears"></span>
          </p>
        </div>
        <div id="fold-end-git.1" class="fold-end"></div>
        <p>
          <span id="2-2" class="clears"></span>
          <span id="2-3">$ cd travis-repos/test-project-1</span>
        </p>
        <p>
          <span id="3-0" class="clears"></span>
        </p>
      '''
      parts = [
        [0, 'travis_fold:start:git.1\r\x1b[0Ktravis_time:start\r\x1b[0K$ git clone git://github.com/travis-repos/test-project-1.git\r\n'],
        [1, 'Cloning into "travis-repos/test-project-1"...\r\n'],
        [2, 'travis_time:finish:start=1406198200403308535,finish=1406198200512171436,duration=108862901\r\x1b[0Ktravis_fold:end:git.1\r\x1b[0Ktravis_time:start\r\x1b[0K$ cd travis-repos/test-project-1\r\n'],
        [3, 'travis_time:finish:start=1406198200519336670,finish=1406198200526430974,duration=7094304\r\x1b[0K']
      ]
      expect(@render parts).toBe html

    it 'works (2)', ->
      html = strip '''
        <p>
          <span id="0-0"></span>
        </p>
        <p>
          <span id="0-1"></span>
        </p>
        <p>
          <span id="0-2" class="clears"></span>
          <span id="0-3">$ rvm use default</span>
        </p>
        <p>
          <span id="0-4"></span>
        </p>
        <p>
          <span id="0-5" class="green">Using /home/travis/.rvm/gems/ruby-1.9.3-p545</span>
          <span id="0-6"></span>
        </p>
        <p>
          <span id="0-7"></span>
        </p>
        <p>
          <span id="0-8" class="clears"></span>
          <span id="0-9">$ export BUNDLE_GEMFILE=$PWD/Gemfile</span>
        </p>
      '''
      part = '''
        \r\n
        travis_time:start\r\x1b[0K$ rvm use default\r\n
        \x1b[32mUsing /home/travis/.rvm/gems/ruby-1.9.3-p545\x1b[0m\r\n
        travis_time:finish:start=1406198200554511643,finish=1406198200768749441,duration=214237798\r\x1b[0K$ export BUNDLE_GEMFILE=$PWD/Gemfile\r\n
      '''
      parts = [[0, part]]
      expect(@render parts).toBe html

