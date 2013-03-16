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
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

  describe 'first', ->
    beforeEach ->
      @render [[0, 'foo\nbar'], [1, 'baz']]

    it 'part', ->
      expect(@log.children.first.id).toBe '0'

    it 'span', ->
      expect(@log.children.first.children.first.id).toBe '0-0'

  describe 'last', ->
    beforeEach ->
      @render [[0, 'foo\nbar'], [1, 'baz']]

    it 'part', ->
      expect(@log.children.last.id).toBe '1'

    it 'span', ->
      expect(@log.children.first.children.last.id).toBe '0-1'

  describe 'prev', ->
    beforeEach ->
      @render [[0, 'foo\nbar'], [1, 'baz']]

    it 'part', ->
      expect(@log.children.last.prev.id).toBe '0'

    it 'span', ->
      expect(@log.children.first.children.last.prev.id).toBe '0-0'

    it 'span with a removed sibling', ->
      @log.children.first.children.last.remove()
      expect(@log.children.last.children.first.prev.id).toBe '0-0'

  describe 'next', ->
    beforeEach ->
      @render [[0, 'foo\nbar'], [1, 'baz']]

    it 'part', ->
      expect(@log.children.first.next.id).toBe '1'

    it 'span', ->
      expect(@log.children.first.children.first.next.id).toBe '0-1'

    it 'span with a removed sibling', ->
      @log.children.first.children.last.remove()
      expect(@log.children.first.children.first.next.id).toBe '1-0'

  describe 'isSequence', ->
    beforeEach ->
      @render [[0, 'foo\nbar'], [1, 'baz'], [3, 'buz']]

    it 'is true on the same part (left to right)', ->
      expect(@log.children.first.children.first.isSequence(@log.children.first.children.last)).toBe true

    it 'is true on the same part (right to left)', ->
      expect(@log.children.first.children.last.isSequence(@log.children.first.children.first)).toBe true

    it 'is true on an adjacent part (left to right)', ->
      expect(@log.children.first.children.first.isSequence(@log.children.first.next.children.last)).toBe true

    it 'is true on an adjacent part (right to left)', ->
      expect(@log.children.first.next.children.last.isSequence(@log.children.first.children.first)).toBe true

    it 'is false on a non-adjacent part (left to right)', ->
      expect(@log.children.first.children.first.isSequence(@log.children.last.children.last)).toBe false

    it 'is false on a non-adjacent part (right to left)', ->
      expect(@log.children.last.children.last.isSequence(@log.children.first.children.first)).toBe false

  # describe 'head', ->
  #   beforeEach ->
  #     log.removeChild(log.firstChild) while log.firstChild
  #     @log = new Log
  #     @render = (parts) -> render(@, parts)

  #   it 'contains nodes that are both dom siblings and immediate neighbors', ->
  #     rescueing @, ->
  #       @render [[1, '.'], [2, '.'], [3, '.']]
  #       span = @log.children.last.children.last.children.last
  #       expect(span.head.map((span) -> span.id).join(', ')).toBe '1-0-0, 2-0-0'

  #   it 'does not contain nodes that are children of a different dom node', ->
  #     rescueing @, ->
  #       @render [[0, 'foo\n'], [1, 'bar']]
  #       span = @log.children.last.children.last.children.last
  #       expect(span.head.map((span) -> span.id).length).toBe 0

  #   it 'does not contain nodes that are not immediate neighbors (parts)', ->
  #     rescueing @, ->
  #       @render [[1, '.'], [3, '.']]
  #       span = @log.children.last.children.last.children.last
  #       expect(span.head.map((span) -> span.id).length).toBe 0


  # describe 'tail', ->
  #   beforeEach ->
  #     log.removeChild(log.firstChild) while log.firstChild
  #     @log = new Log
  #     @render = (parts) -> render(@, parts)

  #   it 'contains nodes that are both dom siblings', ->
  #     rescueing @, ->
  #       @render [[1, '.'], [2, '.'], [3, '.']]
  #       span = @log.children.first.children.first.children.first
  #       expect(span.tail.map((span) -> span.id).join(', ')).toBe '2-0-0, 3-0-0'

  #   it 'does not contain nodes that are children of a different dom node', ->
  #     rescueing @, ->
  #       @render [[0, 'foo\n'], [1, 'bar']]
  #       span = @log.children.first.children.first.children.first
  #       expect(span.tail.map((span) -> span.id).length).toBe 0

  #   # it 'does not contain nodes that are not immediate neighbors (parts)', ->
  #   #   rescueing @, ->
  #   #     @render [[1, '.'], [3, '.']]
  #   #     span = @log.children.first.children.first.children.first
  #   #     expect(span.tail.map((span) -> span.id).length).toBe 0

  # # it 'removing a line fixes prev on the next lines', ->
  # #   rescueing @, ->
  # #     line = (@lines.items.filter (item) -> item.id == '0-1')[0]
  # #     ids  = [line.prev.id, line.next.id]
  # #     prev = line.prev
  # #     next = line.next
  # #     line.remove()
  # #     expect([next.prev.id, prev.next.id]).toEqual ids

  # # it 'removing a span fixes prev on the next spans', ->
  # #   rescueing @, ->
  # #     span = (@lines.first.children.items.filter (item) -> item.id == '0-0-1')[0]
  # #     ids  = [span.prev.id, span.next.id]
  # #     prev = span.prev
  # #     next = span.next
  # #     span.remove()
  # #     expect([next.prev.id, prev.next.id]).toEqual ids


