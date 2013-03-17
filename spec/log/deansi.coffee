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

  it 'random part sizes w/ dot output', ->
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
      <p><span id="0-2" class="clears"></span><span id="1-0" class="clears"></span><span id="1-1">baz</span></p>
    '''
    parts = [
      [1, '\rbaz\r\n'],
      [0, '\u001b[0mfoo\u001b[0mbar\r\n\r']
    ]
    expect(@render parts).toBe html

