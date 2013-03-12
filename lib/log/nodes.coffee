Log.Node = (id) ->
  @id = id
  @children = new Log.Nodes(@)
  @
$.extend Log.Node,
  FOLDS_PATTERN:
    /fold:(start|end):([\w_\-\.]+)/
  create: (id, string) ->
    if fold = string.match(@FOLDS_PATTERN)
      new Log.Fold(id, fold[1], fold[2])
    else
      new Log.Line(id, string)
$.extend Log.Node,
  reinsert: (lines, spans) ->
    console.log "reinsert: #{spans.map((span) -> span.id).join(', ')}"
    span.remove() for span in spans
    line = new Log.Line(spans[spans.length - 1].id.replace(/-[\d]+$/, ''))
    lines.add(line)
    line.render()
    line.addChild(span) for span in spans
    dump(@log)
    # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
$.extend Log.Node.prototype,
  addChild: (node) ->
    @children.add(node)
Log.Node::__defineGetter__ 'log',      -> @parent.log || @parent
Log.Node::__defineGetter__ 'renderer', -> @parent.renderer
Log.Node::__defineGetter__ 'isFirst',  -> @id == @parent.children.first?.id
Log.Node::__defineGetter__ 'isLast',   -> @id == @parent.children.last?.id

Log.Nodes = (parent) ->
  @parent = parent if parent
  @items  = []
  @
$.extend Log.Nodes.prototype,
  add: (item) ->
    ix = (@prevIndex(item.id) || 0) + 1
    @items.splice(ix, 0, item)
    item.parent = @parent if @parent
    item.prev.next = item if item.prev = @items[ix - 1] || @parent?.prev?.children.last
    item.next.prev = item if item.next = @items[ix + 1] || @parent?.next?.children.first
    item.added()
    item
  remove: (item) ->
    item.next.prev = item.prev if item.next
    item.prev.next = item.next if item.prev
    @items.splice(@items.indexOf(item), 1)
    @parent.remove() if @items.length == 0
  prev: (id) ->
    @items[@prevIndex(id)]
  prevIndex: (id) ->
    for ix in [@items.length - 1..0] by -1
      return ix if @items[ix].id < id
  at: (ix) ->
    @items[ix]
  find: (id) ->
    for item in @items
      return item if item.id == id
  each: (func) ->
    @items.slice().forEach(func)
  map: (func) ->
    @items.map(func)
Log.Nodes::__defineGetter__ 'first',  -> @items[0]
Log.Nodes::__defineGetter__ 'last',   -> @items[@length - 1]
Log.Nodes::__defineGetter__ 'length', -> @items.length


Log.Line = (id, string) ->
  Log.Node.apply(@, arguments)
  @string = string
  @ends = !!string[string.length - 1]?.match(/\n/) if string
  @
Log.Line.prototype = $.extend new Log.Node,
  added: ->
    if @string
      @addChild(new Log.Span("#{@id}-#{ix}", span)) for span, ix in Log.Deansi.apply(@string)
    # if (prev = @prev) && !prev.ends && !prev.fold
    #   console.log "P.1 - move #{@id}'s spans into prev (#{prev.id})" if Log.DEBUG
    #   last = @children.last
    #   @prev.join(@)
    #   dump(@log)
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    #   Log.Node.reinsert(@parent.lines, last.tail) if @ends
    # else if (next = @next) && !@ends && !next.fold
    #   console.log "P.2 - move next's #{next.id} spans into self (#{@id})" if Log.DEBUG
    #   @element = @renderer.insert(@data, before: next.element)
    #   last = @children.last
    #   dump(@log)
    #   @join(next)
    #   dump(@log)
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    #   # Log.Node.reinsert(@parent.lines, last.tail) if @ends
    # else if prev = @prev
    #   console.log "P.4 - insert #{@id} after prev (#{prev.id})" if Log.DEBUG
    #   @element = @renderer.insert(@data, after: prev.element)
    #   dump(@log)
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else if next = @next
    #   console.log "P.5 - insert #{@id} before next (#{next.id})" if Log.DEBUG
    #   @element = @renderer.insert(@data, before: next.element)
    #   dump(@log)
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else
    #   console.log "P.6 - insert #{@id} at the beginning of #log" if Log.DEBUG
    #   @element = @renderer.insert(@data)
    #   dump(@log)
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
  join: (other) ->
    other.children.map (span) =>
      span.remove()
      @ends = true if span.ends
      @addChild(span)
      span.render()
      span
  remove: ->
    @renderer.remove(@element)
    @parent.lines.remove(@)
# Log.Line::__defineGetter__ 'ends', ->
#   @children.items.some (span) -> span.ends
Log.Line::__defineGetter__ 'data', ->
  { type: 'paragraph', id: @id, nodes: @children.map (node) -> node.data } # , hidden: @hidden
Log.Line::__defineGetter__ 'tail', ->
  parent = @element.parentNode
  next = @
  tail = []
  tail.push(next) while (next = next.next) && !next.fold && next.element?.parentNode == parent
  tail


Log.Span = (id, data) ->
  Log.Node.apply(@, arguments)
  @data = $.extend(data, id: id)
  @ends = !!data.text[data.text.length - 1]?.match(/\n/)
  @data.text = data.text.replace(/\n$/, '')
  @data.class = ['ends'] if @ends
  @
Log.Span.prototype = $.extend new Log.Node,
  added: ->
    # if @ends && (tail = @tail) && tail.length > 0
    #   # reinsert tail
    if @isFirst && (prev = @parent.prev?.children.prev(@id)) #&& !prev.ends
      @parent.children.remove(@)
      prev.parent.addChild(@)
    # if prev = @prev
    #   console.log "S.1 - insert #{@id} after prev #{prev.id}" if Log.DEBUG
    #   @renderer.insert(@data, after: prev.element)
    # else if next = @next
    #   console.log "S.2 - insert #{@id} before next #{next.id}" if Log.DEBUG
    #   @renderer.insert(@data, before: next.element)
    # else
    #   console.log "S.3 - insert #{@id} into parent #{@parent.id}" if Log.DEBUG
    #   @renderer.insert(@data, into: @parent.element)
  # if @hidden
  #   span.hide() for span in @head
  # else
  #   @hide() if @tail.some (span) -> span.hidden
  remove: ->
    @renderer.remove(@element)
    @parent.children.remove(@)
  siblings: (direction) ->
    siblings = []
    span = @
    siblings.unshift(span) while (span = span[direction]) && span.element?.parentNode == @element.parentNode
    siblings
Log.Span::__defineGetter__ 'element', ->
  document.getElementById(@id)
Log.Span::__defineGetter__ 'head', ->
  @siblings('prev')
Log.Span::__defineGetter__ 'tail', ->
  @siblings('next')
