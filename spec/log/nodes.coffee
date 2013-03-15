describe 'Nodes', ->
  head = (node) ->
    ids = []
    ids.unshift(node) while node = node.prev
    ids

  tail = (node) ->
    ids = []
    ids.push(node) while node = node.next
    ids

  beforeEach ->
    rescueing @, ->
      @log = new Log.Part('0')
      @lines = @log.children
      ids = [
        ['1-1', ['1-1-0', '1-1-2', '1-1-1']],
        ['0-1', ['0-1-1', '0-1-0', '0-1-2']],
        ['0-0', ['0-0-2', '0-0-0', '0-0-1']],
        ['1-0', ['1-0-2', '1-0-0', '1-0-1']]
      ]
      for [id, spans] in ids
        line = @log.addChild(new Log.Line(id))
        line.addChild(new Log.Span(id, ix, { text: '' })) for id, ix in spans

  # it 'inserting lines', ->
  #   expect(@lines.map((node) -> node.id)).toEqual ['0-0', '0-1', '1-0', '1-1']

  # it 'inserting spans', ->
  #   expect(@lines.first.children.map((node) -> node.id)).toEqual ['0-0-0', '0-0-1', '0-0-2']

  # it 'first', ->
  #   expect(@lines.first.id).toBe '0-0'

  # it 'last', ->
  #   expect(@lines.last.id).toBe '1-1'

  # it 'sets next on lines', ->
  #   ids = head(@lines.last).map (node) -> node.id
  #   expect(ids).toEqual ['0-0', '0-1', '1-0']

  # it 'sets prev on lines', ->
  #   ids = tail(@lines.first).map (node) -> node.id
  #   expect(ids).toEqual ['0-1', '1-0', '1-1']

  # it 'sets prev (nested)', ->
  #   ids = head(@lines.last.children.last).map (node) -> node.id
  #   expect(ids).toEqual ['0-0-0', '0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1']

  # it 'sets next (nested)', ->
  #   ids = tail(@lines.first.children.first).map (node) -> node.id
  #   expect(ids).toEqual ['0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1', '1-1-2']

  it 'sets part on lines', ->
    expect(@lines.last.part.id).toBe '0'

  it 'sets part on spans', ->
    expect(@lines.last.children.last.part.id).toBe '0'

  describe 'head', ->
    beforeEach ->
      log.removeChild(log.firstChild) while log.firstChild
      @log = new Log
      @render = (parts) -> render(@, parts)

    it 'contains nodes that are both dom siblings and immediate neighbors', ->
      rescueing @, ->
        @render [[1, '.'], [2, '.'], [3, '.']]
        span = @log.children.last.children.last.children.last
        expect(span.head.map((span) -> span.id).join(', ')).toBe '1-0-0, 2-0-0'

    it 'does not contain nodes that are children of a different dom node', ->
      rescueing @, ->
        @render [[0, 'foo\n'], [1, 'bar']]
        span = @log.children.last.children.last.children.last
        expect(span.head.map((span) -> span.id).length).toBe 0

    it 'does not contain nodes that are not immediate neighbors (parts)', ->
      rescueing @, ->
        @render [[1, '.'], [3, '.']]
        span = @log.children.last.children.last.children.last
        expect(span.head.map((span) -> span.id).length).toBe 0


  describe 'tail', ->
    beforeEach ->
      log.removeChild(log.firstChild) while log.firstChild
      @log = new Log
      @render = (parts) -> render(@, parts)

    it 'contains nodes that are both dom siblings', ->
      rescueing @, ->
        @render [[1, '.'], [2, '.'], [3, '.']]
        span = @log.children.first.children.first.children.first
        expect(span.tail.map((span) -> span.id).join(', ')).toBe '2-0-0, 3-0-0'

    it 'does not contain nodes that are children of a different dom node', ->
      rescueing @, ->
        @render [[0, 'foo\n'], [1, 'bar']]
        span = @log.children.first.children.first.children.first
        expect(span.tail.map((span) -> span.id).length).toBe 0

    # it 'does not contain nodes that are not immediate neighbors (parts)', ->
    #   rescueing @, ->
    #     @render [[1, '.'], [3, '.']]
    #     span = @log.children.first.children.first.children.first
    #     expect(span.tail.map((span) -> span.id).length).toBe 0

  # it 'removing a line fixes prev on the next lines', ->
  #   rescueing @, ->
  #     line = (@lines.items.filter (item) -> item.id == '0-1')[0]
  #     ids  = [line.prev.id, line.next.id]
  #     prev = line.prev
  #     next = line.next
  #     line.remove()
  #     expect([next.prev.id, prev.next.id]).toEqual ids

  # it 'removing a span fixes prev on the next spans', ->
  #   rescueing @, ->
  #     span = (@lines.first.children.items.filter (item) -> item.id == '0-0-1')[0]
  #     ids  = [span.prev.id, span.next.id]
  #     prev = span.prev
  #     next = span.next
  #     span.remove()
  #     expect([next.prev.id, prev.next.id]).toEqual ids


