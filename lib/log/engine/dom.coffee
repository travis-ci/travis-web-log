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
  @lines = for line, ix in string.split(/^/m)
    new Log.Dom.Line(@, ix, line)
  @
$.extend Log.Dom.Part.prototype,
  insert: ->
    line.insert() for line in @lines
  prev: ->
    num  = @num
    prev = @engine.parts[num -= 1] until prev || num < 0
    prev
  next: ->
    num  = @num
    next = @engine.parts[num += 1] until next || num >= @engine.parts.length
    next
  trigger: () ->
    @engine.trigger.apply(@engine, arguments)

Log.Dom.Line = (part, num, line) ->
  @part   = part
  @num    = num
  @ends   = !!line[line.length - 1].match(/\r|\n/)
  @chunks = [new Log.Dom.Chunk(@, 0, line.replace(/\n$/, ''))] # deansi will expand this
  @data   = { type: 'paragraph', nodes: (chunk.data for chunk in @chunks) }
  @
$.extend Log.Dom.Line.prototype,
  insert: ->
    if (prev = @prev()) && !prev.ends
      after = prev.chunks[prev.chunks.length - 1]
      console.log "1 - insert #{@part.num}-#{@num}'s nodes after the last node of prev, id #{after.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, after: after.element) for chunk in @chunks
      next.reinsert() if @ends && next = @next()
    else if (next = @next()) && !@ends
      # insertChunksBefore(prev.chunks.last)
      before = next.chunks[0]
      console.log "2 - insert #{@part.num}-#{@num}'s nodes before the first node of next, id #{before.id}" if Log.DEBUG
      chunk.element = @trigger('insert', chunk.data, before: before.element) for chunk in @chunks
    else if prev
      after = prev.chunks[prev.chunks.length - 1]
      console.log "3 - insert #{@part.num}-#{@num} after the parentNode of the last node of prev, id #{after.id}" if Log.DEBUG
      @element = @trigger('insert', @data, after: after.element.parentNode)
      child = @element.firstChild
      chunk.element = (child = child.nextSibling) for chunk in @chunks
    else if next
      before = next.chunks[0]
      console.log "4 - insert #{@part.num}-#{@num} before the parentNode of the first node of next, id #{before.id}" if Log.DEBUG
      @element = @trigger('insert', @data, before: before.element.parentNode)
      child = @element.firstChild
      (chunk.element = child = child.nextSibling) for chunk in @chunks
    else
      console.log "5 - insert #{@part.num}-#{@num} at the beginning of #log" if Log.DEBUG
      @element = @trigger('insert', @data)
      child = @element.firstChild
      (chunk.element = child = child.nextSibling) for chunk in @chunks
    # console.log document.firstChild.innerHTML
  remove: ->
    # if !node.getAttribute('class')?.match(/fold/)
    element = document.getElementById(@chunks[0].id).parentNode
    @trigger 'remove', chunk.id for chunk in @chunks
    @trigger 'remove', element.id unless element.hasChildNodes()
  reinsert: ->
    @remove()
    @insert()
  prev: ->
    line = @part.lines[@num - 1]
    line || @part.prev()?.lines.slice(-1)[0]
  next: ->
    line = @part.lines[@num + 1]
    line || @part.next()?.lines[0]
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Dom.Chunk = (line, num, text) ->
  @line = line
  @num  = num
  @id   = "#{line.part.num}-#{line.num}-#{num}"
  @text = text
  @data = { type: 'span', id: @id, text: @text }
  @
$.extend Log.Dom.Chunk.prototype,
  prev: ->
    chunk = @line.chunks[@num - 1]
    chunk || @line.prev()?.chunks.slice(-1)[0]
  next: ->
    chunk = @line.chunks[@num + 1]
    chunk || @line.next()?.chunks[0]
  # defold: (string) ->
  #   if matches = string.match(/fold:(start|end):([\w_\-\.]+)/)
  #     { type: 'fold', event: matches[1], name: matches[2] }

