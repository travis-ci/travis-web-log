Log.Node = (id, num) ->
  @id = id
  @num = num
  @key = Log.Node.key(@id)
  @children = new Log.Nodes(@)
  @
Log.extend Log.Node,
  key: (id) ->
    id.split('-').map((i) -> '000000'.concat(i).slice(-6)).join('') if id
Log.extend Log.Node.prototype,
  addChild: (node) ->
    @children.add(node)
  remove: () ->
    @log.remove(@element)
    @parent.children.remove(@)
Object.defineProperty Log.Node::, 'log', {
  get: () -> @_log ||= @parent?.log || @parent
}
Object.defineProperty Log.Node::, 'firstChild', {
  get: () -> @children.first
}
Object.defineProperty Log.Node::, 'lastChild', {
  get: () -> @children.last
}


Log.Nodes = (parent) ->
  @parent = parent if parent
  @items  = []
  @index  = {}
  @
Log.extend Log.Nodes.prototype,
  add: (item) ->
    ix = @position(item) || 0
    @items.splice(ix, 0, item)
    item.parent = @parent if @parent
    prev = (item) -> item = item.prev while item && !item.children.last; item?.children.last
    next = (item) -> item = item.next while item && !item.children.first; item?.children.first
    item.prev.next = item if item.prev = @items[ix - 1] || prev(@parent?.prev)
    item.next.prev = item if item.next = @items[ix + 1] || next(@parent?.next)
    item
  remove: (item) ->
    @items.splice(@items.indexOf(item), 1)
    item.next.prev = item.prev if item.next
    item.prev.next = item.next if item.prev
    @parent.remove() if @items.length == 0
  position: (item) ->
    for ix in [@items.length - 1..0] by -1
      return ix + 1 if @items[ix].key < item.key
  indexOf: ->
    @items.indexOf.apply(@items, arguments)
  slice: ->
    @items.slice.apply(@items, arguments)
  each: (func) ->
    @items.slice().forEach(func)
  map: (func) ->
    @items.map(func)
Object.defineProperty Log.Nodes::, 'first', {
  get: () -> @items[0]
}
Object.defineProperty Log.Nodes::, 'last', {
  get: () -> @items[@length - 1]
}
Object.defineProperty Log.Nodes::, 'length', {
  get: () -> @items.length
}


Log.Part = (id, num, string) ->
  Log.Node.apply(@, arguments)
  @string = string || ''
  @string = @string.replace(/\033\[1000D/gm, '\r')
  @string = @string.replace(/\r+\n/gm, '\n')
  @strings = @string.split(/^/gm) || []
  @slices = (@strings.splice(0, Log.SLICE) while @strings.length > 0)
  @
Log.extend Log.Part,
  create: (log, num, string) ->
    part = new Log.Part(num.toString(), num, string)
    log.addChild(part)
    part.process(0, -1)
Log.Part.prototype = Log.extend new Log.Node,
  remove: ->
    # don't remove parts
  process: (slice, num) ->
    for string in (@slices[slice] || [])
      return if @log.limit?.limited
      # console.log "P processing: #{JSON.stringify(string)}"
      spans = []
      for node in Log.Deansi.apply(string)
        span = Log.Span.create(@, "#{@id}-#{num += 1}", num, node.text, node.class)
        span.render()
        spans.push(span)
      spans[0].line.clear() if spans[0]?.line?.cr
    setTimeout((=> @process(slice + 1, num)), Log.TIMEOUT) unless slice >= @slices.length - 1

newLineAtTheEndRegexp = new RegExp("\n$")
newLineRegexp = new RegExp("\n")
rRegexp = new RegExp("\r")

removeCarriageReturns = (string) ->
  index = string.lastIndexOf("\r")
  return string if index == -1
  string.substr(index + 1)

Log.Span = (id, num, text, classes) ->
  Log.Node.apply(@, arguments)
  if fold = text.match(Log.FOLD)
    @fold  = true
    @event = fold[1]
    @text  = @name = fold[2]
  else if time = text.match(Log.TIME)
    @time  = true
    @event = time[1]
    @name  = time[2]
    @stats = time[3]
  else
    @text  = text
    @text  = removeCarriageReturns(@text)
    @text  = @text.replace(newLineAtTheEndRegexp, '')
    @nl    = !!text[text.length - 1]?.match(newLineRegexp)
    @cr    = !!text.match(rRegexp)
    @class = @cr && ['clears'] || classes
  @
Log.extend Log.Span,
  create: (parent, id, num, text, classes) ->
    span = new Log.Span(id, num, text, classes)
    parent.addChild(span)
    span
  render: (parent, id, num, text, classes) ->
    span = @create(parent, id, num, text, classes)
    span.render()
Log.Span.prototype = Log.extend new Log.Node,
  render: ->
    # if !@fold && !@nl && @next?.cr && @isSequence(@next)
    #   console.log "S.0 skip #{@id}" if Log.DEBUG
    #   @line = @next.line
    #   @remove()
    if @time && @event == 'end'
      console.log "S.0 skip insertion of #{@id} because it is a time end tag" if Log.DEBUG
    else if !@fold && @prev && !@prev.fold && !@prev.nl
      console.log "S.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @log.insert(@data, after: @prev.element)
      @line = @prev.line
    else if !@fold && @next && !@next.fold && !@next.time # && !@nl
      console.log "S.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @log.insert(@data, before: @next.element)
      @line = @next.line
    else
      @line = Log.Line.create(@log, [@])
      @line.render()

    # console.log format document.firstChild.innerHTML + '\n'
    @split(tail) if @nl && (tail = @tail).length > 0
    @log.times.add(@) if @time

  remove: ->
    Log.Node::remove.apply(@)
    @line.remove(@) if @line
  split: (spans) ->
    console.log "S.4 split [#{spans.map((span) -> span.id).join(', ')}]" if Log.DEBUG
    @log.remove(span.element) for span in spans
    # console.log format document.firstChild.innerHTML + '\n'
    line = Log.Line.create(@log, spans)
    line.render()
    line.clear() if line.cr
  clear: ->
    if @prev && @isSibling(@prev) && @isSequence(@prev)
      @prev.clear()
      @prev.remove()
  isSequence: (other) ->
    @parent.num - other.parent.num == @log.children.indexOf(@parent) - @log.children.indexOf(other.parent)
  isSibling: (other) ->
    @element?.parentNode == other.element?.parentNode
  siblings: (type) ->
    siblings = []
    siblings.push(span) while (span = (span || @)[type]) && @isSibling(span)
    siblings
Object.defineProperty Log.Span::, 'data', {
  get: () -> { id: @id, type: 'span', text: @text, class: @class }
}
Object.defineProperty Log.Span::, 'line', {
  get: () -> @_line
  set: (line) ->
    @line.remove(@) if @line
    @_line = line
    @line.add(@)
}
Object.defineProperty Log.Span::, 'element', {
  get: () -> document.getElementById(@id)
}
Object.defineProperty Log.Span::, 'head', {
  get: () -> @siblings('prev').reverse()
}
Object.defineProperty Log.Span::, 'tail', {
  get: () -> @siblings('next')
}


Log.Line = (log) ->
  @log = log
  @spans = []
  @
Log.extend Log.Line,
  create: (log, spans) ->
    if (span = spans[0]) && span.fold
      line = new Log.Fold(log, span.event, span.name)
    else
      line = new Log.Line(log)
    span.line = line for span in spans
    line
Log.extend Log.Line.prototype,
  add: (span) ->
    @cr = true if span.cr
    if @spans.indexOf(span) > -1
      return
    else if (ix = @spans.indexOf(span.prev)) > -1
      @spans.splice(ix + 1, 0, span)
    else if (ix = @spans.indexOf(span.next)) > -1
      @spans.splice(ix, 0, span)
    else
      @spans.push(span)
  remove: (span) ->
    @spans.splice(ix, 1) if (ix = @spans.indexOf(span)) > -1
  render: ->
    if (fold = @prev) && fold.event == 'start' && fold.active
      console.log "L.0 insert #{@id} into fold #{fold.id}" if Log.DEBUG
      fold = @log.folds.folds[fold.name].fold
      @element = @log.insert(@data, into: fold)
    else if @prev
      console.log "L.1 insert #{@spans[0].id} after prev #{@prev.id}" if Log.DEBUG
      @element = @log.insert(@data, after: @prev.element)
    else if @next
      console.log "L.2 insert #{@spans[0].id} before next #{@next.id}" if Log.DEBUG
      @element = @log.insert(@data, before: @next.element)
    else
      console.log "L.3 insert #{@spans[0].id} into #log" if Log.DEBUG
      @element = @log.insert(@data)
    # console.log format document.firstChild.innerHTML + '\n'
  clear: ->
    # cr.clear() if cr = @crs.pop()
    cr.clear() for cr in @crs

Object.defineProperty Log.Line::, 'id', {
  get: () -> @spans[0]?.id
}
Object.defineProperty Log.Line::, 'data', {
  get: () -> { type: 'paragraph', nodes: @nodes }
}
Object.defineProperty Log.Line::, 'nodes', {
  get: () -> @spans.map (span) -> span.data
}
Object.defineProperty Log.Line::, 'prev', {
  get: () -> @spans[0].prev?.line
}
Object.defineProperty Log.Line::, 'next', {
  get: () -> @spans[@spans.length - 1].next?.line
}
Object.defineProperty Log.Line::, 'crs', {
  get: () -> @spans.filter (span) -> span.cr
}

Log.Fold = (log, event, name) ->
  Log.Line.apply(@, arguments)
  @fold  = true
  @event = event
  @name  = name
  @
Log.Fold.prototype = Log.extend new Log.Line,
  render: ->
    # console.log "fold #{@id} prev: #{@prev?.id} next: #{@next?.id}"
    if @prev && @prev.element
      console.log "F.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      element = @prev.element
      @element = @log.insert(@data, after: element)
    else if @next
      console.log "F.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      element = @next.element || @next.element.parentNode
      @element = @log.insert(@data, before: element)
    else
      console.log "F.3 insert #{@id}" if Log.DEBUG
      @element = @log.insert(@data)

    @span.prev.split([@span.next].concat(@span.next.tail)) if @span.next && @span.prev?.isSibling(@span.next)
    # console.log format document.firstChild.innerHTML + '\n'
    @active = @log.folds.add(@data)

Object.defineProperty Log.Fold::, 'id', {
  get: () -> "fold-#{@event}-#{@name}"
}
Object.defineProperty Log.Fold::, 'span', {
  get: () -> @spans[0]
}
Object.defineProperty Log.Fold::, 'data', {
  get: () -> { type: 'fold', id: @id, event: @event, name: @name }
}
