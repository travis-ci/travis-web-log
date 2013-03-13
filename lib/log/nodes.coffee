Log.Node = (id) ->
  @id = id
  @key = Log.Node.key(@id)
  @children = new Log.Nodes(@)
  @
Log.extend Log.Node,
  key: (id) ->
    id.split('-').map((i) -> '000000'.concat(i).slice(-6)).join('') if id
Log.extend Log.Node.prototype,
  addChild: (node) ->
    @children.add(node)
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


Log.Part = (id, string) ->
  Log.Node.apply(@, arguments)
  @string = string || ''
  lines = @string.replace(/\r\n/gm, '\n').split(/^/gm) || []
  @slices = (lines.splice(0, Log.SLICE) while lines.length > 0)
  @
Log.extend Log.Part,
  create: (parent, id, string) ->
    part = new Log.Part(id, string)
    parent.addChild(part)
    part.process(0)
Log.Part.prototype = Log.extend new Log.Node,
  process: (slice) ->
    for line, ix in @slices[slice]
      return if @log.limit?.limited
      ix = slice * Log.SLICE + ix
      if fold = line.match(Log.Fold.PATTERN)
        Log.Fold.create(@, "#{@id}-#{ix}", fold[1], fold[2])
      else
        Log.Line.create(@, "#{@id}-#{ix}", line)
    setTimeout((=> @process(slice + 1)), Log.TIMEOUT) unless slice == @slices.length - 1

Log.Fold = (id, event, name) ->
  Log.Node.apply(@, arguments)
  @fold = true
  @id   = id
  @data = { type: 'fold', id: id, event: event, name: name }
  @
Log.extend Log.Fold,
  PATTERN:
    /fold:(start|end):([\w_\-\.]+)/
  create: (parent, id, event, name) ->
    fold = new Log.Fold(id, event, name)
    parent.addChild(fold)
    fold.render()
    parent.log.folds.add(fold.data)
Log.Fold.prototype = Log.extend new Log.Node,
  render: ->
    if @prev
      console.log "F.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @log.insert(@data, after: @prev.element)
    else if @next
      console.log "F.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @log.insert(@data, before: @next.element)
    else
      console.log "F.3 insert #{@id}" if Log.DEBUG
      @log.insert(@data)
    # console.log format document.firstChild.innerHTML + '\n'
Log.Fold::__defineGetter__ 'element', ->
  document.getElementById(@id)

Log.Line = (id, string) ->
  Log.Node.apply(@, arguments)
  @string = string
  @
Log.extend Log.Line,
  create: (parent, id, string) ->
    line = new Log.Line(id, string)
    parent.addChild(line)
    Log.Span.create(line, "#{id}-#{ix}", span) for span, ix in Log.Deansi.apply(string) if string
Log.Line.prototype = Log.extend new Log.Node,
  render: ->
    if @prev
      console.log "P.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @log.insert(@data, after: @prev.element)
    else if @next
      console.log "P.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @log.insert(@data, before: @next.element)
    else
      console.log "P.3 insert #{@id}" if Log.DEBUG
      @log.insert(@data)
Log.Line::__defineGetter__ 'data', ->
  { type: 'paragraph', nodes: @children.map (node) -> node.data }
Log.Line::__defineGetter__ 'element', ->
  @children.first.element.parentNode


Log.Span = (id, data) ->
  Log.Node.apply(@, arguments)
  @data = $.extend(data, id: id)
  @ends = !!data.text[data.text.length - 1]?.match(/\n/)
  @hidden = !!data.text.match(/\r/)
  @data.text = data.text.replace(/.*\r/gm, '').replace(/\n$/, '')
  @data.class = ['hidden'] if @hidden
  @
Log.extend Log.Span,
  create: (parent, id, data) ->
    span = new Log.Span(id, data)
    parent.addChild(span)
    span.render()
Log.Span.prototype = Log.extend new Log.Node,
  render: ->
    if @prev && !@prev.ends
      console.log "S.1 insert #{@id} after prev #{@prev.id}" if Log.DEBUG
      @log.insert(@data, after: @prev.element)
    else if @next && !@ends
      console.log "S.2 insert #{@id} before next #{@next.id}" if Log.DEBUG
      @log.insert(@data, before: @next.element)
    else
      @parent.render()
    # console.log format document.firstChild.innerHTML + '\n'

    if @ends && (tail = @tail).length > 0
      @split(tail)

    if @hidden
      span.hide() for span in @head
    else if @tail.some((span) -> span.hidden)
      @hide()
  hide: ->
    @log.hide(@element) unless @hidden
    @hidden = true
  split: (spans) ->
    console.log "S.3 split #{spans.map((span) -> span.id).join(', ')}"
    @log.remove(span.element) for span in spans
    first.parent.render() if first = spans.shift()
    span.render() for span in spans
  isSibling: (other) ->
    @element.parentNode == other.element.parentNode
  siblings: (type) ->
    siblings = []
    span = @
    siblings.push(span) while (span = span[type]) && @isSibling(span)
    siblings
Log.Span::__defineGetter__ 'element', ->
  document.getElementById(@id)
Log.Span::__defineGetter__ 'head', ->
  @siblings('prev').reverse()
Log.Span::__defineGetter__ 'tail', ->
  @siblings('next')
