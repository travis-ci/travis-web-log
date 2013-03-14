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

  describe 'carriage returns and newlines', ->
    it 'nl', ->
      html = @render [[0, 'foo\n']]
      console.log html
      expect(html).toBe '<p><span id="0-0-0">foo</span></p>'

    it 'cr nl', ->
      html = @render [[0, 'foo\r\n']]
      console.log html
      expect(html).toBe '<p><span id="0-0-0">foo</span></p>'

    it 'cr cr nl', ->
      html = @render [[0, 'foo\r\r\n']]
      console.log html
      expect(html).toBe '<p><span id="0-0-0">foo</span></p>'

    it 'cr', ->
      html = @render [[0, 'foo\r']]
      console.log html
      expect(html).toBe '<p><span id="0-0-0" class="hidden"></span></p>'

  format = (html) ->
    html.replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span')

  it 'foo', ->
    rescueing @, ->
      console.log format @render [
        [0, 'foo'],
        [3, 'baz'],
        [2, '\r'],
        [1, 'bar'],
      ]


  describe 'progress', ->
    beforeEach ->
      @html = strip '''
        <p>
          <span id="0-0-0" class="hidden"></span>
          <span id="0-1-0" class="hidden">1%</span>
          <span id="1-0-0" class="hidden"></span>
          <span id="1-1-0" class="hidden"></span>
          <span id="2-0-0" class="hidden"></span>
          <span id="2-1-0">Done.</span>
        </p>
      '''

    it 'clears the line if the carriage return sits on the next part (ordered)', ->
      expect(@render [[0, '0%\r1%'], [1, '\r2%\r'], [2, '\rDone.']]).toBe @html

    it 'clears the line if the carriage return sits on the next part (unordered, 1)', ->
      expect(@render [[1, '\r2%\r'], [2, '\rDone.'], [0, '0%\r1%']]).toBe @html

    it 'clears the line if the carriage return sits on the next part (unordered, 3)', ->
      expect(@render [[2, '\rDone.'], [1, '\r2%\r'], [0, '0%\r1%']]).toBe @html

  it 'simulating git clone', ->
    rescueing @, ->
      html = strip '''
        <p><span id="0-0-0">Cloning into 'jsdom'...</span></p>
        <p><span id="1-0-0">remote: Counting objects: 13358, done.</span></p>
        <p>
          <span id="2-0-0" class="hidden"></span>
          <span id="3-0-0" class="hidden"></span>
          <span id="4-0-0" class="hidden"></span>
          <span id="5-0-0" class="hidden"></span>
          <span id="6-0-0">remote: Compressing objects 100% (5/5), done.</span></p>
        <p>
          <span id="7-0-0" class="hidden"></span>
          <span id="8-0-0" class="hidden"></span>
          <span id="9-0-0" class="hidden"></span>
          <span id="10-0-0" class="hidden"></span>
          <span id="11-0-0">Receiving objects 100% (5/5), done.</span></p>
        <p>
          <span id="12-0-0" class="hidden"></span>
          <span id="13-0-0" class="hidden"></span>
          <span id="14-0-0" class="hidden"></span>
          <span id="15-0-0" class="hidden"></span>
          <span id="16-0-0">Resolving deltas: 100% (5/5), done.</span>
        </p>
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

  it 'random part sizes w/ dot output', ->
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

