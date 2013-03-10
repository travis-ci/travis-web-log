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
      @nodes.insert(node)
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
  @nodes = []
  @
$.extend Log.Dom.Nodes.prototype,
  at: (ix) ->
    @nodes[ix]
  insert: (node) ->
    @nodes[node.num] = node
    node.insert()
  remove: (node) ->
    @nodes.splice(node.num, 1)

Log.Dom.Nodes::__defineGetter__ 'length', -> @nodes.length
Log.Dom.Nodes::__defineGetter__ 'first',  -> @nodes[0]
Log.Dom.Nodes::__defineGetter__ 'last',   -> @nodes[@length - 1]

Log.Dom.Node = ->
$.extend Log.Dom.Node,
  FOLDS_PATTERN:
    /fold:(start|end):([\w_\-\.]+)/
  create: (part, num, string) ->
    if fold = string.match(@FOLDS_PATTERN)
      new Log.Dom.Fold(part, num, fold[1], fold[2])
    else
      new Log.Dom.Paragraph(part, num, string)
  reinsert: (nodes) ->
    console.log "reinsert: #{nodes.map((node) -> node.id).join(', ')}"
    node.remove() for node in nodes
    node.part.nodes.insert(node) for node in nodes
    console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
Log.Dom.Node::__defineGetter__ 'prev', ->
  num = @num
  prev = @part.nodes.at(num -= 1) until prev || num < 0
  prev || @part.prev?.nodes.last
Log.Dom.Node::__defineGetter__ 'next', ->
  num = @num
  next = @part.nodes.at(num += 1) until next || num >= @part.nodes.length
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
    @element = if (prev = @prev) && !@prev.element.parentNode.getAttribute('class')?.match('fold')
      console.log "F.1 - insert #{@id} (#{@part.num}-#{@num}) after #{prev.id}" if Log.DEBUG
      @trigger 'insert', @data, after: prev.element
    else if (next = @next) && !@next.element.parentNode.getAttribute('class')?.match('fold')
      console.log "F.2 - insert #{@id} (#{@part.num}-#{@num}) before #{next.id}" if Log.DEBUG
      @trigger 'insert', @data, before: next.element
    else if prev && prev.element.parentNode.id?.match('fold')
      console.log "F.3 - insert #{@id} (#{@part.num}-#{@num}) after #{prev.element.parentNode.id}" if Log.DEBUG
      @trigger 'insert', @data, after: prev.element.parentNode
    else if prev && prev.element.id?.match('fold')
      console.log "F.4 - insert #{@id} (#{@part.num}-#{@num}) after #{prev.element.id}" if Log.DEBUG
      @trigger 'insert', @data, after: prev.element.parentNode
    else
      console.log prev
      console.log document.firstChild.innerHTML.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div') + '\n'
      console.log "F.5 - insert #{@id} (#{@part.num}-#{@num})" if Log.DEBUG
      @trigger 'insert', @data
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Paragraph = (part, num, string) ->
  @part  = part
  @num   = num
  @id    = "#{@part.num}-#{@num}"
  @ends  = !!string[string.length - 1]?.match(/\n/)
  @spans = new Log.Dom.Spans(@, string.replace(/\n$/, ''))
  @data  = { type: 'paragraph', num: @part.num, hidden: @hidden, nodes: (span.data for span in @spans) }
  @
Log.Dom.Paragraph.prototype = $.extend new Log.Dom.Node,
  # 1 - The previous line does not have a line ending, so the current line's spans are
  #     injected into that (previous) paragraph. If the current line has a line ending and
  #     there's a next line then we need to re-insert that next line so it gets split out
  #     of the current one.
  # 2 - The current line does not have a line ending and there's a next line, so the current
  #     line's spans are injected into that (next) paragraph.
  # 3 - There's a previous line which has a line ending, so we're going to insert the current
  #     line after the previous one.
  # 4 - There's a next line and the current line has a line ending, so we're going to insert
  #     the current line before the next one.
  # 5 - There are neither previous nor next lines.
  insert: ->
    if (prev = @prev) && !prev.ends && !prev.fold
      after = prev.spans.last.element
      console.log "P.1 - insert #{@id}'s spans after the last node of prev, id #{after.id}" if Log.DEBUG
      span.insert(after: after) for span in @spans.slice().reverse()
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
      Log.Dom.Node.reinsert(@tail) if @ends
    else if (next = @next) && !@ends && !next.fold
      before = next.spans.first.element
      console.log "P.2 - insert #{@id}'s spans before the first node of next, id #{before.id}" if Log.DEBUG
      span.insert(before: before) for span in @spans
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    else if prev?.fold && prev?.element.getAttribute('class')?.match(' fold')
      console.log "P.3 - append #{@id} to fold #{prev.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, after: prev.element.firstChild
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    else if prev
      console.log "P.4 - insert #{@id} after the parentNode of the last node of prev, id #{prev.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, after: prev.element
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    else if next
      console.log "P.5 - insert #{@id} before the parentNode of the first node of next, id #{next.id}" if Log.DEBUG
      @element = @trigger 'insert', @data, before: next.element
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    else
      console.log "P.6 - insert #{@id} at the beginning of #log" if Log.DEBUG
      @element = @trigger 'insert', @data
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'

  remove: ->
    element = @element
    @trigger 'remove', span.element for span in @spans
    @trigger 'remove', element unless element.childNodes.length > 1
    @part.nodes.remove(@)
  trigger: ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Paragraph::__defineSetter__ 'element', (element) ->
  child = element.firstChild
  (span.element = child = child.nextSibling) for span in @spans
Log.Dom.Paragraph::__defineGetter__ 'element', ->
  @spans.first.element.parentNode
Log.Dom.Paragraph::__defineGetter__ 'tail', ->
  parent = @element.parentNode
  next = @
  tail = []
  tail.push(next) while (next = next.next) && !next.fold && next.element?.parentNode == parent
  tail


Log.Dom.Spans = (parent, string) ->
  @push.apply(@, @parse(parent, string))
Log.Dom.Spans.prototype = $.extend new Array,
  parse: (parent, string) ->
    new Log.Dom.Span(parent, ix, span) for span, ix in Log.Deansi.apply(string)

Log.Dom.Spans::__defineGetter__ 'first', -> @[0]
Log.Dom.Spans::__defineGetter__ 'last',  -> @[@.length - 1]


Log.Dom.Span = (parent, num, data) ->
  @parent   = parent
  @num    = num
  @id     = "#{parent.part.num}-#{parent.num}-#{num}"
  @data   = $.extend(data, id: @id)
  @hidden = true if data.text.match(/\r/)
  @data.text = data.text.replace(/^.*\r/gm, '')
  @data.class = ['hidden'] if @hidden
  @
$.extend Log.Dom.Span.prototype,
  insert: (pos) ->
    @element = @trigger('insert', @data, pos)
    if @hidden
      span.hide() for span in @head
    else
      @hide() if @tail.some (span) -> span.hidden
  hide: ->
    @trigger('hide', @id) unless @hidden
    @hidden = true
  siblings: (direction) ->
    siblings = []
    span = @
    siblings.unshift(span) while (span = span[direction]) && span.element?.parentNode == @element.parentNode
    siblings
  trigger: ->
    @parent.trigger.apply(@parent, arguments)
Log.Dom.Span::__defineGetter__ 'head', ->
  @siblings('prev')
Log.Dom.Span::__defineGetter__ 'tail', ->
  @siblings('next')
Log.Dom.Span::__defineGetter__ 'prev', ->
  span = @parent.spans[@num - 1]
  span || @parent.prev?.spans?.last
Log.Dom.Span::__defineGetter__ 'next', ->
  span = @parent.spans[@num + 1]
  span || @parent.next?.spans?.first
