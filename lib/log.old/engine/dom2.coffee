Log.Dom = (log) ->
  @log = log
  @parts = []
  @nodes = new Log.Dom.Nodes(@)
  @
$.extend Log.Dom.prototype,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      @parts[num] = true
      @insert(num, string)
  # trigger: () ->
  #   @log.trigger.apply(@log, arguments)
  SLICE: 500
  insert: (num, string) ->
    lines  = string.split(/^/gm) || [] # hu?
    slices = (lines.splice(0, @SLICE) while lines.length > 0)
    ix = -1
    next = =>
      @insertSlice(num, slices.shift(), ix += 1)
      setTimeout(next, 50) unless slices.length == 0
    next()
  insertSlice: (num, lines, start) ->
    for line, ix in lines || []
      break if @log.limit?.limited # hrm ...
      @nodes.insert(Log.Dom.Node.create(@, [num, start * @SLICE + ix], line))


# Log.Dom.Part = (engine, num, string) ->
#   @engine = engine
#   @num = num
#   @string = string.replace(/\r\n/gm, '\n')
#   @
# $.extend Log.Dom.Part.prototype,
#   remove: ->
#     @engine.parts.splice(@num, 1)
#   # trigger: ->
#   #   @engine.trigger.apply(@engine, arguments)
# Log.Dom.Part::__defineGetter__ 'prev', ->
#   num  = @num
#   prev = @engine.parts[num -= 1] until prev || num < 0
#   prev
# Log.Dom.Part::__defineGetter__ 'next', ->
#   num  = @num
#   next = @engine.parts[num += 1] until next || num >= @engine.parts.length
#   next


Log.Dom.Nodes = (parent) ->
  @parent = parent
  @content = []
  @
$.extend Log.Dom.Nodes.prototype,
  at: (ix) ->
    @content[ix]
  insert: (node) ->
    @content[node.num] = node
    # node.insert()
  remove: (node) ->
    @content.splice(@content.indexOf(node), 1)
    # @parent.remove() if @content.length == 0

Log.Dom.Nodes::__defineGetter__ 'length', -> @content.length
Log.Dom.Nodes::__defineGetter__ 'first',  -> @content[0]
Log.Dom.Nodes::__defineGetter__ 'last',   -> @content[@content.length - 1]

Log.Dom.Node = ->
$.extend Log.Dom.Node,
  FOLDS_PATTERN:
    /fold:(start|end):([\w_\-\.]+)/
  create: (parent, ids, string) ->
    if fold = string.match(@FOLDS_PATTERN)
      new Log.Dom.Fold(parent, ids, fold[1], fold[2])
    else
      new Log.Dom.Paragraph(parent, ids, string)
  # reinsert: (nodes) ->
  #   console.log "reinsert: #{nodes.map((node) -> node.id).join(', ')}"
  #   node.remove() for node in nodes
  #   node.parent.nodes.insert(node) for node in nodes
  #   console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
Log.Dom.Node::__defineGetter__ 'prev', ->
  num = @num
  # console.log @parent
  # console.log [@id, @num, (@parent.nodes.content.map (n) -> n.id), @parent.prev?.id, @parent.prev?.nodes.last]
  prev = @parent.nodes.at(num -= 1) until prev || num < 0
  prev || @parent.prev?.nodes.last
Log.Dom.Node::__defineGetter__ 'next', ->
  num = @num
  next = @parent.nodes.at(num += 1) until next || num >= @parent.nodes.length
  next || @parent.next?.nodes.first


# Log.Dom.Fold = (parent, num, event, name) ->
#   @parent = parent
#   @ends = true
#   @fold = true
#   @num  = num
#   @id   = "fold-#{event}-#{name}"
#   @data = { type: 'fold', id: @id, event: event, name: name }
#   @
# Log.Dom.Fold.prototype = $.extend new Log.Dom.Node,
#   insert: ->
#     fail
#     # @element = if (prev = @prev) && !@prev.element.parentNode.getAttribute('class')?.match('fold')
#     #   console.log "F.1 - insert #{@id} (#{@parent.num}-#{@num}) after #{prev.id}" if Log.DEBUG
#     #   @trigger 'insert', @data, after: prev.element
#     # else if (next = @next) && !@next.element.parentNode.getAttribute('class')?.match('fold')
#     #   console.log "F.2 - insert #{@id} (#{@parent.num}-#{@num}) before #{next.id}" if Log.DEBUG
#     #   @trigger 'insert', @data, before: next.element
#     # else if prev && prev.element.parentNode.id?.match('fold')
#     #   console.log "F.3 - insert #{@id} (#{@parent.num}-#{@num}) after #{prev.element.parentNode.id}" if Log.DEBUG
#     #   @trigger 'insert', @data, after: prev.element.parentNode
#     # else if prev && prev.element.id?.match('fold')
#     #   console.log "F.4 - insert #{@id} (#{@parent.num}-#{@num}) after #{prev.element.id}" if Log.DEBUG
#     #   @trigger 'insert', @data, after: prev.element.parentNode
#     # else
#     #   console.log "F.5 - insert #{@id} (#{@parent.num}-#{@num})" if Log.DEBUG
#     #   @trigger 'insert', @data
#   trigger: () ->
#     @parent.trigger.apply(@parent, arguments)

Log.Dom.Paragraph = (parent, ids, string) ->
  @parent = parent
  @ids   = ids
  @id    = ids.join('-')
  @ends  = !!string[string.length - 1]?.match(/\n/)
  @spans = new Log.Dom.Spans(@, ids, string.replace(/\n$/, ''))
  # @data  = { type: 'paragraph', num: @parent.num, hidden: @hidden, nodes: (span.data for span in @spans.content) }
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
      console.log "P.1 - move #{@id}'s spans into prev (#{prev.id})" if Log.DEBUG
      @spans.content.slice().forEach (span) -> prev.spans.insert(span)
      @remove()
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
      # Log.Dom.Node.reinsert(@tail) if @ends
    else if (next = @next) && !@ends && !next.fold
      console.log "P.2 - move next's (#{next.id}) spans into #{@id}" if Log.DEBUG
      @next.spans.content.slice().forEach (span) => @spans.insert(span)
      next.remove()
      # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else if prev?.fold && prev?.element.getAttribute('class')?.match(' fold')
    #   console.log "P.3 - append #{@id} to fold #{prev.id}" if Log.DEBUG
    #   @element = @trigger 'insert', @data, after: prev.element.firstChild
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else if prev
    #   console.log "P.4 - insert #{@id} after the parentNode of the last node of prev, id #{prev.id}" if Log.DEBUG
    #   @element = @trigger 'insert', @data, after: prev.element
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else if next
    #   console.log "P.5 - insert #{@id} before the parentNode of the first node of next, id #{next.id}" if Log.DEBUG
    #   @element = @trigger 'insert', @data, before: next.element
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'
    # else
    #   console.log "P.6 - insert #{@id} at the beginning of #log" if Log.DEBUG
    #   @element = @trigger 'insert', @data
    #   # console.log document.firstChild.innerHTML.replace(/<\/p>/gm, '</p>\n') + '\n'

  remove: ->
    @parent.nodes.remove(@)

  # remove: ->
  #   element = @element
  #   @trigger 'remove', span.element for span in @spans
  #   @trigger 'remove', element unless element.childNodes.length > 1
  #   @parent.nodes.remove(@)
  # trigger: ->
  #   @parent.trigger.apply(@parent, arguments)

Log.Dom.Paragraph::__defineGetter__ 'id', ->
  "#{@parent.num}-#{@num}"
# Log.Dom.Paragraph::__defineSetter__ 'element', (element) ->
#   child = element.firstChild
#   (span.element = child = child.nextSibling) for span in @spans.content
# Log.Dom.Paragraph::__defineGetter__ 'element', ->
#   @spans.first.element.parentNode
# Log.Dom.Paragraph::__defineGetter__ 'tail', ->
#   parent = @element.parentNode
#   next = @
#   tail = []
#   tail.push(next) while (next = next.next) && !next.fold && next.element?.parentNode == parent
#   tail


Log.Dom.Spans = (parent, ids, string) ->
  @parent = parent
  @content = @parse(parent, ids, string)
  @
$.extend Log.Dom.Spans.prototype,
  parse: (parent, ids, string) ->
    new Log.Dom.Span(parent, ids.concat([ix]), span) for span, ix in Log.Deansi.apply(string)
  at: (ix) ->
    @content[ix]
  indexOf: (span) ->
    @content.indexOf(span)
  insert: (span) ->
    console.log 'insert', span.id
    span.parent.spans.remove(span)
    span.parent = @parent
    head = @content.filter (s) -> s.id < span.id
    ix = @content.indexOf(prev) + 1 if prev = head[head.length - 1]
    @content.splice(ix || 0, 0, span)
    # span.insert()
  prepend: (span) ->
    span.parent.spans.remove(span)
    span.parent = @parent
    @content.unshift(span)
    span.insert()
  # reverse: ->
  #   @content.reverse()
  remove: (span) ->
    @content.splice(@content.indexof(span), 1)

Log.Dom.Spans::__defineGetter__ 'first', -> @content[0]
Log.Dom.Spans::__defineGetter__ 'last',  -> @content[@content.length - 1]


Log.Dom.Span = (parent, ids, data) ->
  @parent = parent
  @ids    = ids
  @id     = ids.join('-')
  @data   = $.extend(data, id: @id)
  @hidden = true if data.text.match(/\r/)
  @data.text = data.text.replace(/^.*\r/gm, '')
  @data.class = ['hidden'] if @hidden
  @
$.extend Log.Dom.Span.prototype,
  insert: ->
    if prev = @prev
      console.log "S.1 - insert #{@id} after prev #{prev.id}" if Log.DEBUG
      @insertAt(after: prev.element)
    else if next = @next
      console.log "S.2 - insert #{@id} before next #{next.id}" if Log.DEBUG
      @insertAt(before: next.element)
    else
      console.log "S.2 - insert #{@id} into parent #{@parent.id}" if Log.DEBUG
      @insertAt(into: @parent.element)
  insertAt: (pos) ->
    @element = @trigger('insert', @data, pos)
    # if @hidden
    #   span.hide() for span in @head
    # else
    #   @hide() if @tail.some (span) -> span.hidden
  # hide: ->
  #   @trigger('hide', @id) unless @hidden
  #   @hidden = true
  # siblings: (direction) ->
  #   siblings = []
  #   span = @
  #   siblings.unshift(span) while (span = span[direction]) && span.element?.parentNode == @element.parentNode
  #   siblings
  # trigger: ->
  #   @parent.trigger.apply(@parent, arguments)
# Log.Dom.Span::__defineGetter__ 'head', ->
#   @siblings('prev')
# Log.Dom.Span::__defineGetter__ 'tail', ->
#   @siblings('next')

Log.Dom.Span::__defineGetter__ 'prev', ->
  console.log @num
  span = @parent.spans.at(@num - 1)
  span || @parent.prev?.spans?.last

# Log.Dom.Span::__defineGetter__ 'prev', ->
#   span = @parent.spans.at(@parent.spans.indexOf(@) - 1)
#   span || @parent.prev?.spans?.last
# Log.Dom.Span::__defineGetter__ 'next', ->
#   span = @parent.spans.at(@parent.spans.indexOf(@) + 1)
#   span || @parent.next?.spans?.first




















