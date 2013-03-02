Object.prototype.clone = ->
  clone = {}
  clone[name] = @[name] for name in @
  clone

Log.Chunks = (log) ->
  @log = log
  @parts = []
  @
$.extend Log.Chunks.prototype,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      part = new Log.Chunks.Part(@, num, string)
      @parts[num] = part
      @parts[num].insert()
  trigger: () ->
    @log.trigger.apply(@log, arguments)

Log.Chunks.Part = (engine, num, string) ->
  @engine = engine
  @num = num
  @chunks = for chunk, ix in string.split(/^/m)
    line = chunk[chunk.length - 1].match(/\r|\n/)
    type = if line then 'Line' else 'Chunk'
    new Log.Chunks[type](@, ix, chunk)
  @
$.extend Log.Chunks.Part.prototype,
  insert: ->
    chunk.insert() for chunk in @chunks
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

Log.Chunks.Chunk = (part, num, string) ->
  @part   = part
  @num    = num
  @string = string
  @id     = "#{part?.num}-#{num}"
  @isFold = string?.indexOf('fold') != -1
  @nodes  = @parse() if string
  @
$.extend Log.Chunks.Chunk.prototype,
  parse: () ->
    [{ type: 'span', id: "#{@id}-0", text: @string }] # deansi will expand this
  insert: ->
    if (next = @next()) && next.isLine
      @trigger 'insert', @nodes, before: next.nodes[0].nodes[0].id
    else if next
      @trigger 'insert', @nodes, before: next.nodes[0].id
    else if (prev = @prev()) && !prev.isLine
      @trigger 'insert', @nodes, after: prev.nodes[prev.nodes.length - 1].id
    else
      @trigger 'insert', [{ type: 'paragraph', id: @id, nodes: @nodes }], before: next
  remove: ->
    # if !node.getAttribute('class')?.match(/fold/)
    for node in @nodes
      @trigger 'remove', @id
      @trigger 'remove', node.id for node in node.nodes if node.nodes
  reinsert: ->
    @remove()
    @insert()
  prevLine: ->
    prev = @prev()
    prev = prev.prev() while prev && !prev.isLine
    prev
  nextLine: ->
    next = @next()
    next = next.next() while next && !next.isLine
    next
  prev: ->
    chunk = @part.chunks[@num - 1]
    chunk || @part.prev()?.chunks.slice(-1)[0]
  next: ->
    chunk = @part.chunks[@num + 1]
    chunk || @part.next()?.chunks[0]
  trigger: () ->
    @part.trigger.apply(@part, arguments)

Log.Chunks.Line = (part, num, string) ->
  Log.Chunks.Chunk.call(@, part, num, string.slice(0, string.length - 1))
  @isLine = true
  @
Log.Chunks.Line.prototype = $.extend new Log.Chunks.Chunk,
  parse: () ->
    [{ type: 'paragraph', id: @id, nodes: [{ type: 'span', id: "#{@id}-0", text: @string}] }] # deansi will expand this
  insert: ->
    if (prev = @prev()) && !prev.isLine
      @trigger 'insert', @nodes[0].nodes, after: prev.nodes[0].id
      document.getElementById(@nodes[0].nodes[0].id).parentNode.setAttribute('id', @id) # hax0rrrr!
      next.reinsert() if @isLine && (next = @next())
    else if prev
      @trigger 'insert', @nodes, after: prev.id
    else if next = @nextLine()
      @trigger 'insert', @nodes, before: next.id
    else
      @trigger 'insert', @nodes, before: undefined

