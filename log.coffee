# ugh. needed so this can be run both in the browser and in specs
# coffeescript would prepend `var $`, which would break in the browser
`if(typeof window == 'undefined' && typeof exports == 'object') {
  $ = require('./vendor/jquery.fake.js').$;
  require('./vendor/ansiparse.js');
} else {
  exports = window
}`

Log = (string) ->
  @listeners = []
  @parts = []
  @
$.extend Log.prototype,
  trigger: () ->
    args = Array::slice.apply(arguments)
    event = args[0]
    @trigger('start', event) unless event == 'start' || event == 'stop'
    listener.notify.apply(listener, [@].concat(args)) for listener in @listeners
    @trigger('stop', event) unless event == 'start' || event == 'stop'
  set: (num, string) ->
    return if @parts[num]
    @parts[num] = new Log.Part(@, num, string)
    @parts[num].insert()

Log.Buffer = (log, options) ->
  @num = -1
  @log = log
  @parts = []
  @options = $.extend({ interval: 100, timeout: 500 }, options || {})
  @schedule()
  @
$.extend Log.Buffer.prototype,
  set: (num, string) ->
    @parts[num] = { string: string, time: (new Date).getTime() }
  flush: ->
    for part, num in @parts
      break unless part
      delete @parts[num]
      @log.set(num, part.string)
    @schedule()
  schedule: ->
    setTimeout((=> @flush()), @options.interval)

Log.Part = (log, num, string) ->
  @log = log
  @num = num
  @lines = for line, ix in string.split(/^/m)
    new Log.Line(@, ix, line)
  @
$.extend Log.Part.prototype,
  insert: ->
    new Log.Context(@log, @).insert()
  head: ->
    head = []
    line = @lines[0]
    while (line = line?.prev()) && !line.isNewline()
      head.unshift(line)
    head
  tail: ->
    tail = []
    line = @lines[@lines.length - 1]
    while line = line?.next()
      tail.push(line)
      break if line?.isNewline()
    tail
  prev: ->
    num  = @num
    prev = @log.parts[num -= 1] until prev || num < 0
    prev
  next: ->
    num  = @num
    next = @log.parts[num += 1] until next || num >= @log.parts.length
    next

Log.Line = (part, num, string) ->
  @part = part
  @num  = num
  @id   = "#{part.num}-#{num}"
  @string = string
  @
$.extend Log.Line.prototype,
  prev: ->
    line = @part.lines[@num - 1]
    line || @part.prev()?.lines.slice(-1)[0]
  next: ->
    line = @part.lines[@num + 1]
    line || @part.next()?.lines[0]
  isNewline: ->
    @string[@string.length - 1] == "\n"
  clone: ->
    new Log.Line(@part, @num, @string)

Log.Context = (log, part) ->
  @log   = log
  @part  = part
  @head  = part.head()
  @tail  = part.tail()
  @lines = @join(@head.concat(part.lines).concat(@tail))
  @
$.extend Log.Context.prototype,
  insert: ->
    ids = @head.concat(@tail).map (line) -> line.id
    @log.trigger('remove', ids) unless ids.length == 0
    @log.trigger('insert', @after(), @nodes())
  nodes: ->
    @lines.map (line) =>
      string = line.string
      nodes = @deansi(string)
      { id: line.id, nodes: nodes, hidden: string == '' }
  join: (all) ->
    lines = []
    while line = all.pop()
      if lines.length == 0 || line.isNewline()
        lines.unshift(line.clone())
      else
        lines[0].string = line.string + lines[0].string
    lines
  after:  ->
    line = @part.lines[0]?.prev()
    line = line.prev() while line && !line.isNewline()
    line?.id
  deansi: (string) ->
    Log.Deansi.apply(string)

Log.Deansi =
  apply: (string) ->
    string = string.replace(/.*(\033\[K\n|\r(?!\n))/gm, '')
    # string = string.replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
    result = []
    ansiparse(string).forEach (part) =>
      result.push(@node(part))
    # result.replace(/\033/g, '')
    result

  classes: (part) ->
    # console.log(part)
    result = []
    result.push(part.foreground)         if part.foreground
    result.push("bg-#{part.background}") if part.background
    result.push('bold')                  if part.bold
    result.push('italic')                if part.italic
    result if result.length > 0

  node: (part) ->
    if classes = @classes(part)
      { type: 'span', class: classes, text: part.text }
    else
      { type: 'text', text: part.text }

Log.Metrics = ->
  @values = {}
  @
$.extend Log.Metrics.prototype,
  start: (name) ->
    @started = (new Date).getTime()
  stop: (name) ->
    @values[name] ||= []
    @values[name].push((new Date).getTime() - @started)
  summary: ->
    metrics = {}
    for name, values of @values
      metrics[name] =
        avg: (values.reduce((a, b) -> a + b) / values.length)
        count: values.length
    metrics

Log.Listener = ->
$.extend Log.Listener.prototype,
  notify: (log, event, num) ->
    # console.log Array::slice.call(arguments)
    @[event].apply(@, [log].concat(Array::slice.call(arguments, 2))) if @[event]

Log.Instrumenter = ->
Log.Instrumenter.prototype = $.extend new Log.Listener,
  start: (log, event) ->
    log.metrics ||= new Log.Metrics
    log.metrics.start(event)
  stop: (log, event) ->
    log.metrics.stop(event)

Log.JqueryRenderer = ->
Log.JqueryRenderer.prototype = $.extend new Log.Listener,
  remove: (log, ids) ->
    $("#log ##{id}").remove() for id in ids

  insert: (log, after, data) ->
    html = (data.map (data) => @render(data))
    after && $("#log ##{after}").after(html) || $('#log').prepend(html).find('p')
    # $('#log').renumber()

  render: (data) ->
    nodes = for node in data.nodes
      text = node.text.replace(/\n/gm, '')
      text = "<span class=\"#{node.class}\">#{text}</span>" if node.type == 'span'
      "<p id=\"#{data.id}\"#{@style(data)}><a id=\"\"></a>#{text}</p>"
    nodes.join("\n")

  style: (data) ->
    data.hidden && 'display: none;' || ''

Log.FragmentRenderer = ->
  @frag = document.createDocumentFragment()
  @para = @createParagraph()
  @span = @createSpan()
  @text = document.createTextNode('')
  @

Log.FragmentRenderer.prototype = $.extend new Log.Listener,
  remove: (log, ids) ->
    for id in ids
      node = document.getElementById(id)
      node.parentNode.removeChild(node) if node

  insert: (log, after, data) ->
    node = @render(data)
    if after
      after = document.getElementById(after)
      @insertAfter(node, after)
    else
      log = document.getElementById('log')
      log.appendChild(node)

  render: (datas) ->
    frag = @frag.cloneNode(true)
    frag.appendChild(@renderParagraph(data)) for data in datas
    frag

  renderParagraph: (data) ->
    para = @para.cloneNode(true)
    para.setAttribute('id', data.id)
    para.setAttribute('style', 'display: none;') if data.hidden
    for node in data.nodes
      node = (node.type == 'span') && @renderSpan(node) || @renderText(node)
      para.appendChild(node)
    para

  renderSpan: (data) ->
    span = @span.cloneNode(true)
    span.setAttribute('class', data.class)
    span.lastChild.nodeValue = data.text.replace(/\n/gm, '')
    span

  renderText: (data) ->
    text = @text.cloneNode(true)
    text.nodeValue = data.text.replace(/\n/gm, '')
    text

  createParagraph: ->
    para = document.createElement('div')
    para.appendChild(document.createElement('a'))
    para

  createSpan: ->
    span = document.createElement('span')
    span.appendChild(document.createTextNode(''))
    span

  insertAfter: (node, after) ->
    if after.nextSibling
      after.parentNode.insertBefore(node, after.nextSibling)
    else
      after.parentNode.appendChild(node)

$.fn.renumber = ->
  num = 1
  @find('p a').each (ix, el) ->
    $(el).attr('id', "L#{num}").html(num)
    num += 1

exports.Log = Log
