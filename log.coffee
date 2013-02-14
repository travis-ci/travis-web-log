# ugh. needed so this can be run both in the browser and in specs
# coffeescript would prepend `var $`, which would break in the browser
`if(typeof window == 'undefined' && typeof exports == 'object') {
  $ = require('./vendor/jquery.fake.js').$;
  require('./vendor/ansiparse.js');
} else {
  exports = window
}`

Log = (string) ->
  @parts = []
  @listeners = []
  @set(0, string) if string
  @
$.extend Log.prototype,
  trigger: () ->
    listener.notify.apply(listener, arguments) for listener in @listeners
  set: (num, string) ->
    return if @parts[num]
    @parts[num] = new Log.Part(@, num, string)
    @parts[num].insert()

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
      string = @deansi(string)
      { id: line.id, text: string.replace(/\n/gm, ''), hidden: string == '' }
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
    result = ''
    ansiparse(string).forEach (part) =>
      result += @span(part.text, @classes(part))
    # result.replace(/\033/g, '')
    result

  classes: (part) ->
    # console.log(part)
    result = []
    result.push(part.foreground)         if part.foreground
    result.push("bg-#{part.background}") if part.background
    result.push('bold')                  if part.bold
    result.push('italic')                if part.italic
    result

  span: (string, classes) ->
    if classes?.length
      "<span class='#{classes.join(' ')}'>#{string}</span>"
    else
      string

Log.Renderer = ->
$.extend Log.Renderer.prototype,
  notify: (event, num) ->
    # console.log Array::slice.call(arguments)
    @[event].apply(@, Array::slice.call(arguments, 1))

Log.JqueryRenderer = ->
Log.JqueryRenderer.prototype = $.extend new Log.Renderer,
  remove: (ids) ->
    $("#log ##{id}").remove() for id in ids

  insert: (after, data) ->
    html = (data.map (data) => @render(data)).join("\n")
    after && $("#log ##{after}").after(html) || $('#log').prepend(html).find('p')
    # $('#log').renumber()

  render: (node) ->
    style = node.hidden && 'display: none;' || ''
    "<p id=\"#{node.id}\"#{style}><a id=\"\"></a>#{node.text}</p>"

Log.FragmentRenderer = ->
  @node = @createNode()
  @fragment = document.createDocumentFragment()
  @

Log.FragmentRenderer.prototype = $.extend new Log.Renderer,
  remove: (ids) ->
    for id in ids
      node = document.getElementById(id)
      node.parentNode.removeChild(node) if node

  insert: (after, data) ->
    node = @render(data)
    if after
      after = document.getElementById(after)
      @insertAfter(node, after)
    else
      log = document.getElementById('log')
      log.appendChild(node)

  insertAfter: (node, after) ->
    if after.nextSibling
      after.parentNode.insertBefore(node, after.nextSibling)
    else
      after.parentNode.appendChild(node)

  render: (data) ->
    fragment = @cloneFragment()
    fragment.appendChild(@renderNode(data)) for data in data
    fragment

  renderNode: (data) ->
    node = @cloneNode()
    node.setAttribute('id', data.id)
    node.setAttribute('style', 'display: none;') if data.hidden
    node.lastChild.nodeValue = data.text
    node

  createNode: ->
    node = document.createElement('div')
    node.appendChild(document.createElement('a'))
    node.appendChild(document.createTextNode(''))
    node

  cloneNode: ->
    @node.cloneNode(true)

  cloneFragment: ->
    @fragment.cloneNode(true)

$.fn.renumber = ->
  num = 1
  @find('p a').each (ix, el) ->
    $(el).attr('id', "L#{num}").html(num)
    num += 1

exports.Log = Log
