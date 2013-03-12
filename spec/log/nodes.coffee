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
      @lines = new Log.Nodes(@)
      ids = [
        ['1-1', ['1-1-0', '1-1-2', '1-1-1']],
        ['0-1', ['0-1-1', '0-1-0', '0-1-2']],
        ['0-0', ['0-0-2', '0-0-0', '0-0-1']],
        ['1-0', ['1-0-2', '1-0-0', '1-0-1']]
      ]
      for [id, spans] in ids
        line = @lines.add(new Log.Line(id, ''))
        line.children.first.remove()
        line.addChild(new Log.Span(id, {})) for id in spans

  it 'inserting lines', ->
    expect(@lines.map((node) -> node.id)).toEqual ['0-0', '0-1', '1-0', '1-1']

  it 'inserting spans', ->
    expect(@lines.first.children.map((node) -> node.id)).toEqual ['0-0-0', '0-0-1', '0-0-2']

  it 'first', ->
    expect(@lines.first.id).toBe '0-0'

  it 'last', ->
    expect(@lines.last.id).toBe '1-1'

  it 'sets next on lines', ->
    ids = head(@lines.last).map (node) -> node.id
    expect(ids).toEqual ['0-0', '0-1', '1-0']

  it 'sets prev on lines', ->
    ids = tail(@lines.first).map (node) -> node.id
    expect(ids).toEqual ['0-1', '1-0', '1-1']

  it 'sets prev (nested)', ->
    ids = head(@lines.last.children.last).map (node) -> node.id
    expect(ids).toEqual ['0-0-0', '0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1']

  it 'sets next (nested)', ->
    ids = tail(@lines.first.children.first).map (node) -> node.id
    expect(ids).toEqual ['0-0-1', '0-0-2', '0-1-0', '0-1-1', '0-1-2', '1-0-0', '1-0-1', '1-0-2', '1-1-0', '1-1-1', '1-1-2']

  it 'removing a line fixes prev on the next lines', ->
    line = @lines.find('0-1')
    ids  = [line.prev.id, line.next.id]
    prev = line.prev
    next = line.next
    line.remove()
    expect([next.prev.id, prev.next.id]).toEqual ids

  it 'removing a span fixes prev on the next spans', ->
    span = @lines.first.children.find('0-0-1')
    ids  = [span.prev.id, span.next.id]
    prev = span.prev
    next = span.next
    span.remove()
    expect([next.prev.id, prev.next.id]).toEqual ids

