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
Log.Node::__defineGetter__ 'log',        -> @_log ||= @parent?.log || @parent
Log.Node::__defineGetter__ 'firstChild', -> @children.first
Log.Node::__defineGetter__ 'lastChild',  -> @children.last


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
    item.prev.next = item if item.prev = @items[ix - 1] || @parent?.prev?.children.last
    item.next.prev = item if item.next = @items[ix + 1] || @parent?.next?.children.first
    item
  remove: (item) ->
    @items.splice(@items.indexOf(item), 1)
    item.next.prev = item.prev if item.next
    item.prev.next = item.next if item.prev
    # console.log @items.length
    @parent.remove() if @items.length == 0
  position: (item) ->
    for ix in [@items.length - 1..0] by -1
      return ix + 1 if @items[ix].key < item.key
  each: (func) ->
    @items.slice().forEach(func)
  map: (func) ->
    @items.map(func)
Log.Nodes::__defineGetter__ 'first',  -> @items[0]
Log.Nodes::__defineGetter__ 'last',   -> @items[@length - 1]
Log.Nodes::__defineGetter__ 'length', -> @items.length
# Log.Nodes::__defineGetter__ 'hasImmediatePrev', -> prev && (prev == @items[ix - 1] || @parent.num == prev.parent.num)


Log.Part = (id, num, string) ->
  Log.Node.apply(@, arguments)
  @string = string || ''
  @lines = @string.replace(/\r+\n/gm, '\n').split(/^/gm) || []
  # @slices = (lines.splice(0, Log.SLICE) while lines.length > 0)
  @
Log.extend Log.Part,
  create: (parent, num, string) ->
    part = new Log.Part(num.toString(), num, string)
    parent.addChild(part)
    for string in part.lines
      Log.Span.create(part, num, num, span) for span, num in Log.Deansi.apply(string)
    # part.process(0)
Log.Part.prototype = Log.extend new Log.Node,
  # process: (slice) ->
  #   for line, ix in (@slices[slice] || [])
  #     return if @log.limit?.limited
  #     num = slice * Log.SLICE + ix
  #     if fold = line.match(Log.Fold.PATTERN)
  #       Log.Fold.create(@, "#{@id}-#{ix}", num, fold[1], fold[2])
  #     else
  #       Log.Line.create(@, "#{@id}-#{ix}", num, line)
  #   setTimeout((=> @process(slice + 1)), Log.TIMEOUT) unless slice >= @slices.length - 1


# Log.Fold = (id, num, event, name) ->
#   Log.Node.apply(@, arguments)
#   @fold  = true
#   @id    = id
#   @event = event
#   @name  = name
#   @data  = { type: 'fold', id: id, event: event, name: name }
#   @
# Log.extend Log.Fold,
#   PATTERN:
#     /fold:(start|end):([\w_\-\.]+)/
#   create: (parent, id, num, event, name) ->
#     fold = new Log.Fold(id, num, event, name)
#     parent.addChild(fold)
#     fold.render()
#     fold.active = parent.log.folds.add(fold.data)
# Log.Fold.prototype = Log.extend new Log.Node,
#   render: ->
#     if @prev
#       console.log "F.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
#       @log.insert(@data, after: @prev.element)
#     else if @next
#       console.log "F.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
#       @log.insert(@data, before: @next.element)
#     else
#       console.log "F.3 insert #{@id}" if Log.DEBUG
#       @log.insert(@data)
#     # console.log format document.firstChild.innerHTML + '\n'
# Log.Fold::__defineGetter__ 'element', -> document.getElementById(@id)


Log.Line = (id, num, string) ->
  Log.Node.apply(@, arguments)
  @string = string
  @
Log.extend Log.Line,
  create: (parent, id, num, string) ->
    line = new Log.Line(id, num, string)
    parent.addChild(line)
    Log.Span.create(line, "#{id}-#{num}", num, span) for span, num in Log.Deansi.apply(string) if string
Log.Line.prototype = Log.extend new Log.Node,
  render: ->
    if (fold = @prev) && fold.event == 'start' && fold.active
      console.log "P.1 insert #{@id} into fold #{fold.id}" if Log.DEBUG
      element = @log.folds.folds[fold.name].fold
      @log.insert(@data, into: element)
      if element.childNodes.length > 2 && !(classes = element.getAttribute('class')).match(/active/)
        element.setAttribute('class', "#{classes} active")
    else if @prev
      console.log "P.2 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @element = @log.insert(@data, after: @prev.element)
    else if @next
      console.log "P.3 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @element = @log.insert(@data, before: @next.element)
    else
      console.log "P.4 insert #{@id}" if Log.DEBUG
      @element = @log.insert(@data)
  clear: ->
    spans = []
    span = @children.first
    spans.push(span) while span && !span.clears && (span = span.next)
    console.log spans.map (span) -> span.id

Log.Line::__defineGetter__ 'part',    -> @parent
Log.Line::__defineGetter__ 'data',    -> { type: 'paragraph', nodes: @children.map (node) -> node.data }
# Log.Line::__defineGetter__ 'element', -> document.getElementById(@id)


Log.Span = (id, num, data) ->
  Log.Node.apply(@, arguments)
  @data = $.extend(data, id: id)
  @ends = !!data.text[data.text.length - 1]?.match(/\n/)
  @clears = !!data.text.match(/\r/)
  @data.text = data.text.replace(/.*\r/gm, '').replace(/\n$/, '')
  @data.class = ['clears'] if @clears
  @
Log.extend Log.Span,
  create: (parent, id, num, data) ->
    span = new Log.Span(id, num, data)
    parent.addChild(span)
    span.render()
Log.Span.prototype = Log.extend new Log.Node,
  render: ->
    if @prev && !@prev.ends
      console.log "S.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @parent.children.remove(@)
      @prev.parent.addChild(@)
      # @parent = @prev.parent
      @log.insert(@data, after: @prev.element)
    else if @next && !@ends
      console.log "S.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @parent.children.remove(@)
      @next.parent.addChild(@)
      # @parent = @next.parent
      @log.insert(@data, before: @next.element)
    else
      console.log @id, @prev?.id, @next?.id
      @parent.render()
    console.log format document.firstChild.innerHTML + '\n'
    dump @log

    # if @ends && (tail = @tail).length > 0
    #   @split(tail)

    # @parent.clears = true if @clears
    # console.log @parent.id
    # @parent.clear() if @parent.clears

    # # TODO this might hide things that would need to be un-hidden later on,
    # # e.g. when lines are split. not sure what's the best approach ...
    # if @clears
    #   # for all siblings, when the sibling is on the immediate previous
    #   # part, clear it
    #   span.remove() for span in @head
    # else if @tail.some((span) -> span.clears)
    #   @remove()
  hide: ->
    @log.hide(@element) unless @clears
    @clears = true
  split: (spans) ->
    # console.log "S.3 split #{spans.map((span) -> span.id).join(', ')}" if Log.DEBUG
    # @log.remove(span.element) for span in spans
    # first.parent.render() if first = spans.shift()
    # # span.render() for span in spans
    # console.log format document.firstChild.innerHTML + '\n'
  isSibling: (other) ->
    @element?.parentNode == other.element?.parentNode
  # isNeighbor: (other) ->
  #   Math.abs(@part.num - other.part.num) <= 1
  siblings: (type) ->
    siblings = []
    span = @
    next = @
    siblings.push(span = next) while (next = next[type]) && span.isSibling(next) ## && span.isNeighbor(next)
    siblings
Log.Span::__defineGetter__ 'part',    -> @parent.parent
Log.Span::__defineGetter__ 'element', -> document.getElementById(@id)
Log.Span::__defineGetter__ 'head',    -> @siblings('prev').reverse()
Log.Span::__defineGetter__ 'tail',    -> @siblings('next')
