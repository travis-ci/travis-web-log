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

format = (html) ->
  html.replace(/<div/gm, '\n<div').replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span')
strip = (string) ->
  string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '')

Log.Dom.Part = (engine, num, string) ->
  @engine = engine
  @num = num
  @string = string.replace(/\r\n/gm, '\n')
  @nodes = new Log.Dom.Nodes(@)
  @
$.extend Log.Dom.Part.prototype,
  SLICE: 500
  insert: ->
    lines  = @string.split(/^/gm) || [] # hu?
    slices = (lines.splice(0, @SLICE) while lines.length > 0)
    ix = -1
    next = =>
      @insertSlice(slices.shift(), ix += 1)
      setTimeout(next, 50) unless slices.length == 0
    next()
  insertSlice: (lines, start) ->
    for line, ix in lines || []
      break if @engine.log.limit?.limited # hrm ...
      node = Log.Dom.Node.create(@, start * @SLICE + ix, line)
      @nodes.push(node)
      node.insert()
      console.log format strip document.firstChild.innerHTML
      console.log '\n'
  trigger: () ->
    @engine.trigger.apply(@engine, arguments)
Log.Dom.Part::__defineGetter__ 'prev', ->
  num  = @num
  prev = @engine.parts[num -= 1] until prev || num < 0
  prev
Log.Dom.Part::__defineGetter__ 'next', ->
  num  = @num
  next = @engine.parts[num += 1] until next || num >= @engine.parts.length
  next


Log.Dom.Nodes = (part) ->
  @part = part
  @
Log.Dom.Nodes.prototype = new Array
Log.Dom.Nodes::__defineGetter__ 'first', -> @[0]
Log.Dom.Nodes::__defineGetter__ 'last',  -> @[@.length - 1]


Log.Dom.Node = ->
$.extend Log.Dom.Node,
  FOLDS_PATTERN:
    /fold:(start|end):([\w_\-\.]+)/
  create: (part, num, string) ->
    if fold = string.match(@FOLDS_PATTERN)
      new Log.Dom.Fold(part, num, fold[1], fold[2])
    else
      new Log.Dom.Line(part, num, string)

Log.Dom.Node::__defineGetter__ 'prev', ->
  num = @num
  prev = @part.nodes[num -= 1] until prev || num < 0
  prev || @part.prev?.nodes.last
Log.Dom.Node::__defineGetter__ 'next', ->
  num = @num
  next = @part.nodes[num += 1] until next || num >= @part.nodes.length
  next || @part.next?.nodes.first


Log.Dom.Fold = (part, num, event, name) ->
  @part = part
  @ends = true
  @fold = true
  @num  = num
  @id   = "fold-#{event}-#{name}"
  @data = { type: 'fold', id: @id, event: event, name: name }
  @
Log.Dom.Fold.prototype = $.extend new Log.Dom.Node,
  insert: ->
    @element = if prev = @prev
      console.log "F - insert fold #{@id} after #{prev.element.id}" if Log.DEBUG
      @trigger 'insert', @data, after: prev.element
    else if next = @next
      console.log "F - insert fold #{@id} before #{next.element.id}" if Log.DEBUG
      @trigger 'insert', @data, before: next.element
    else
      console.log "F - insert fold #{@id}" if Log.DEBUG
      @trigger 'insert', @data
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Line = (part, num, line) ->
  @part   = part
  @num    = num
  @id     = "#{@part.num}-#{@num}"
  @ends   = !!line[line.length - 1]?.match(/\r|\n/)
  @hidden = !!line.match(/\r/)
  @chunks = new Log.Dom.Chunks(@, line.replace(/\n$/, '').replace(/\r/g, ''))
  @data   = { type: 'paragraph', num: @part.num, hidden: @hidden, nodes: (chunk.data for chunk in @chunks) }
  @
Log.Dom.Line.prototype = $.extend new Log.Dom.Node,
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
    if (prev = @prev) && !prev.ends && !prev.fold
      after = prev.chunks.last.element
      console.log "1 - insert #{@id}'s nodes after the last node of prev, id #{after.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, after: after) for chunk in @chunks.slice().reverse()
      if @ends && (next = @next) && next.reinsert
        next.remove()
        next.element = next.trigger 'insert', next.data, after: @element
        if current = next.next
          while current
            current.reinsert()
            current = current.next
    else if (next = @next) && !@ends && !next.fold
      before = next.chunks.first.element
      console.log "2 - insert #{@id}'s nodes before the first node of next, id #{before.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, before: before) for chunk in @chunks
    else if prev
      console.log "3 - insert #{@id} after the parentNode of the last node of prev, id #{prev.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, after: prev.element
    else if next
      console.log "4 - insert #{@id} before the parentNode of the first node of next, id #{next.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, before: next.element
    else
      console.log "5 - insert #{@id} at the beginning of #log" if Log.DEBUG
      @element = @trigger 'insert', @data

  remove: ->
    element = @element
    @trigger 'remove', chunk.element for chunk in @chunks
    @trigger 'remove', element unless element.hasChildNodes()
  reinsert: ->
    console.log "1 - reinsert #{@id}" if Log.DEBUG
    @remove()
    @insert()
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Line::__defineSetter__ 'element', (element) ->
  child = element.firstChild
  (chunk.element = child = child.nextSibling) for chunk in @chunks
Log.Dom.Line::__defineGetter__ 'element', ->
  @chunks.first.element.parentNode


Log.Dom.Chunks = (parent, line) ->
  @push.apply(@, @parse(parent, line))
Log.Dom.Chunks.prototype = $.extend new Array,
  parse: (parent, string) ->
    new Log.Dom.Chunk(parent, ix, chunk) for chunk, ix in Log.Deansi.apply(string)

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

