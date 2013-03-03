Log.Dom = (log) ->
  @log = log
  @parts = []
  @
$.extend Log.Dom.prototype,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      part = new Log.Dom.Part(@, num, string)
      @parts[num] = part
      @parts[num].insert()
  trigger: () ->
    @log.trigger.apply(@log, arguments)


Log.Dom.Part = (engine, num, string) ->
  @engine = engine
  @num = num
  @string = string.replace(/\r\n/gm, '\n')
  @nodes = new Log.Dom.Nodes()
  @
$.extend Log.Dom.Part.prototype,
  FOLDS:
    /fold:(start|end):([\w_\-\.]+)/
  insert: ->
    for string, ix in @string.split(/^/gm)
      node = @node(string, ix)
      @nodes.push(node)
      node.insert()
  node: (string, ix) ->
    if fold = string.match(@FOLDS)
      new Log.Dom.Fold(@, ix, fold[1], fold[2])
    else
      new Log.Dom.Line(@, ix, string)
  trigger: () ->
    @engine.trigger.apply(@engine, arguments)
  # defold: (string) ->
  #   { event: match[1], name: match[2] } if match = string.match(@FOLDS)

Log.Dom.Part::__defineGetter__ 'prev', ->
  num  = @num
  prev = @engine.parts[num -= 1] until prev || num < 0
  prev
Log.Dom.Part::__defineGetter__ 'next', ->
  num  = @num
  next = @engine.parts[num += 1] until next || num >= @engine.parts.length
  next

Log.Dom.Nodes = () ->
  @
Log.Dom.Nodes.prototype = new Array
Log.Dom.Nodes::__defineGetter__ 'first', -> @[0]
Log.Dom.Nodes::__defineGetter__ 'last',  -> @[@.length - 1]

Log.Dom.Fold = (part, num, event, name) ->
  @part  = part
  @num   = num
  @event = event
  @name  = name
  @id    = "#{@part.num}-#{@num}"
  @ends  = true
  @data  = { type: 'fold', id: @id, num: part.num, event: event, name: name }
  @
$.extend Log.Dom.Fold.prototype,
  insert: ->
    pos = if prev = @prev
      { after: prev.element }
    else if next = @next
      { before: next.element }
    @element = @trigger 'insert', @data, pos || {}
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Fold::__defineGetter__ 'prev', ->
  @part.nodes[@num - 1] || @part.prev?.nodes.last
Log.Dom.Fold::__defineGetter__ 'next', ->
  @part.nodes[@num + 1] || @part.next?.nodes.first

Log.Dom.Line = (part, num, line) ->
  @part   = part
  @num    = num
  @id     = "#{@part.num}-#{@num}"
  @ends   = !!line[line.length - 1].match(/\r|\n/)
  @hidden = !!line.match(/\r/)
  @chunks = new Log.Dom.Chunks(@, line.replace(/\n$/, ''))
  @data   = { type: 'paragraph', num: @part.num, hidden: @hidden, nodes: (chunk.data for chunk in @chunks) }
  @
$.extend Log.Dom.Line.prototype,
  # 1 - The previous line does not have a line ending, so the current line's chunks are
  #     injected into that (previous) paragraph. If the current line has a line ending and
  #     there's a next line then we need to re-insert that next line so it gets split out
  #     of the current one.
  # 2 - The current line does not have a line ending and there's a next line, so the current
  #     line's chunks are injected into that (next) paragraph.
  # 3 - There's a previous line which has a line ending, so we're going to insert the current
  #     line after the previous one.
  # 4 - There's a next line and the current line has a line ending, so we're going to insert
  #     the current line before the next one.
  # 5 - There are neither previous nor next lines.
  insert: ->
    if (prev = @prev) && !prev.ends
      after = prev.chunks.last.element
      console.log "1 - insert #{@id}'s nodes after the last node of prev, id #{after.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, after: after) for chunk in @chunks
      next.reinsert() if @ends && next = @next
    else if (next = @next) && !@ends
      before = next.chunks.first.element
      console.log "2 - insert #{@id}'s nodes before the first node of prev, id #{before.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, before: before) for chunk in @chunks
    else if prev
      console.log "3 - insert #{@id} after the parentNode of the last node of prev, id #{prev.element.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, after: prev.element
    else if next
      console.log "4 - insert #{@id} before the parentNode of the first node of next, id #{next.element.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, before: next.element
    else
      console.log "5 - insert #{@id} at the beginning of #log" if Log.DEBUG
      @element = @trigger 'insert', @data

  remove: ->
    element = @chunks.first.element.parentNode
    # if !element.getAttribute('class')?.match(/fold/)
    @trigger 'remove', chunk.id for chunk in @chunks
    @trigger 'remove', element.id unless element.hasChildNodes()
  reinsert: ->
    @remove()
    @insert()
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Line::__defineSetter__ 'element', (element) ->
  child = element.firstChild
  (chunk.element = child = child.nextSibling) for chunk in @chunks
Log.Dom.Line::__defineGetter__ 'element', ->
  @chunks.first.element.parentNode
Log.Dom.Line::__defineGetter__ 'prev', ->
  @part.nodes[@num - 1] || @part.prev?.nodes.last
Log.Dom.Line::__defineGetter__ 'next', ->
  @part.nodes[@num + 1] || @part.next?.nodes.first


Log.Dom.Chunks = (parent, line) ->
  data = @parse(parent, line)
  @push.apply(@, data)
  @
Log.Dom.Chunks.prototype = $.extend new Array,
  FOLDS:
    /fold:(start|end):([\w_\-\.]+)/
  parse: (parent, string) ->
    # fold = @defold(string)
    # data = if fold then [fold] else @deansi(string)
    # new Log.Dom.Chunk(parent, ix, chunk) for chunk, ix in data
    new Log.Dom.Chunk(parent, ix, chunk) for chunk, ix in @deansi(string)
  defold: (string) ->
    { type: 'fold', event: match[1], name: match[2] } if match = string.match(@FOLDS)
  deansi: (string) ->
    Log.Deansi.apply(string)

Log.Dom.Chunks::__defineGetter__ 'first', -> @[0]
Log.Dom.Chunks::__defineGetter__ 'last',  -> @[@.length - 1]


Log.Dom.Chunk = (line, num, data) ->
  @line = line
  @num  = num
  @id   = "#{line.part.num}-#{line.num}-#{num}"
  @data = $.extend(data, id: @id)
  @
$.extend Log.Dom.Chunk.prototype,
  prev: ->
    chunk = @line.chunks[@num - 1]
    chunk || @line.prev()?.chunks.slice(-1)[0]
  next: ->
    chunk = @line.chunks[@num + 1]
    chunk || @line.next()?.chunks[0]

