# TestListener = ->
#   @events = []
#   @
# $.extend TestListener.prototype,
#   notify: (event) ->
#     @events.push(Array::slice.call(arguments))
#     @[event]
#
# TestRenderer = ->
#   @lines = []
#   @
# TestRenderer.prototype = $.extend new Log.InnerHtmlRenderer,
#   insert: (log, after, nodes) ->
#     html = @render(nodes)
#     if after and node = @find(after)
#       Array::splice.apply(@lines, [@lines.indexOf(node) + 1, 0].concat(html.split("\n")))
#     else
#       Array::splice.apply(@lines, [0, 0].concat(html.split("\n")))
#
#   remove: (log, ids) ->
#     for id in ids
#       line = @find(id)
#       @lines.splice(@lines.indexOf(line), 1) if line
#
#   find: (id) ->
#     for line in @lines
#       return line if line.match(///id="#{id}"///)
#
# describe 'Log', ->
#   beforeEach ->
#     @renderer = new TestRenderer
#     @log = new Log
#     @log.listeners.push(@renderer)
#
#   describe 'set', ->
#     it 'reorders parts', ->
#       @log.set 0, "foo\n\n"
#       @log.set 2, "buz\n"
#       @log.set 1, "bar\nbaz\n"
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="0-0"><a></a>foo</p><p id="0-1"><a></a></p>
#         <p id="1-0"><a></a>bar</p><p id="1-1"><a></a>baz</p><p id="2-0"><a></a>buz</p>
#       '''
#
#     it 'joins chunks that belong to the same line', ->
#       @log.set 3, '...\nbar\n...'
#       @log.set 2, '...'
#       @log.set 0, "foo\n"
#       @log.set 1, '...'
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="0-0"><a></a>foo</p>
#         <p id="3-0"><a></a>.........</p>
#         <p id="3-1"><a></a>bar</p>
#         <p id="3-2"><a></a>...</p>
#       '''
#
#     it 'joins chunks (2)', ->
#       @log.set 0, "a\n..."
#       @log.set 1, "...\nb"
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="0-0"><a></a>a</p>
#         <p id="1-0"><a></a>......</p>
#         <p id="1-1"><a></a>b</p>
#       '''
#
#     it 'works when tail starts with an \n-terminated line', ->
#       @log.set 2, "...\n"
#       @log.set 1, '...'
#       @log.set 3, "b\n"
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="2-0"><a></a>......</p>
#         <p id="3-0"><a></a>b</p>
#       '''
#
#     it 'works when clearing a line followed by an \n-terminated line', ->
#       @log.set 4, "b\n"
#       @log.set 1, "..."
#       @log.set 2, "\x1B[K\n"
#       @log.set 3, "a\n"
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="2-0" style="display: none;"><a id=""></a></p>
#         <p id="3-0"><a></a>a</p>
#         <p id="4-0"><a></a>b</p>
#       '''
#
#     it 'works when concating lines followed by an \n-terminated line', ->
#       @log.set 4, "b\n"
#       @log.set 1, "..."
#       @log.set 2, "...\n"
#       @log.set 3, "a\n"
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="2-0"><a></a>......</p>
#         <p id="3-0"><a></a>a</p>
#         <p id="4-0"><a></a>b</p>
#       '''
#
#     it 'works with an intermediary empty string', ->
#       @log.set 2, "b\n"
#       @log.set 0, "a\n"
#       @log.set 1, ''
#       expect(@renderer.lines.join("\n")).toBe '''
#         <p id="0-0"><a></a>a</p>
#         <p id="2-0"><a></a>b</p>
#       '''
#
# describe 'Log.Context', ->
#   beforeEach ->
#     @log = new Log
#     @log.set 0, "foo\n..."
#     @log.set 2, "...\nbuz"
#     @listener = new TestListener
#
#   describe 'insert', ->
#     it 'triggers "remove" with the ids of the heading and tailing lines', ->
#       @log.listeners.push(@listener)
#       @log.set 1, '.'
#       expect(@listener.events[0]).toEqual(['remove', ['0-1', '2-0']])
#
#     it 'triggers "insert" with the generated html', ->
#       @log.listeners.push(@listener)
#       @log.set 1, '.'
#       event = @listener.events[1]
#       expect(event[0]).toBe('insert')
#       expect(event[1]).toBe('0-0')
#       expect(event[2]).toEqual('<p id="2-0"><a id=""></a>.......</p>')
#
# describe 'Log.Part', ->
#   beforeEach ->
#     @log = new Log
#     @log.set 0, "foo\nbar\n"
#
#   it 'splits the given lines', ->
#     expect(@log.parts[0].lines.length).toBe(2)
#
#   describe 'head', ->
#     it 'is empty if the last line of previous part is a newline', ->
#       @log.set 1, '...'
#       tail = @log.parts[0].head()
#       expect(tail.length).toBe(0)
#
#     it 'finds all preceeding lines that are not newlines', ->
#       @log.set 1, '...'
#       @log.set 2, "...\nbar"
#       head = @log.parts[2].head()
#       expect(head.length).toBe(1)
#       expect(head[0].id).toBe('1-0')
#
#   describe 'tail', ->
#     it 'is empty if there are no succeeding lines', ->
#       tail = @log.parts[0].tail()
#       expect(tail.length).toBe(0)
#
#     it 'finds all succeeding lines up to the first newline (and including it)', ->
#       @log.set 1, "foo\n..."
#       @log.set 2, "..."
#       @log.set 3, "...\n"
#       tail = @log.parts[1].tail()
#       expect(tail.length).toBe(2)
#       expect(tail[0].id).toBe('2-0')
#       expect(tail[1].id).toBe('3-0')
#
#   describe 'prev', ->
#     it 'finds the previous part, skipping over gaps', ->
#       @log.set 2, 'baz'
#       expect(@log.parts[2].prev().num).toBe(0)
#
#   describe 'next', ->
#     it 'finds the next part, skipping over gaps', ->
#       @log.set 2, 'baz'
#       expect(@log.parts[0].next().num).toBe(2)
#
# describe 'Log.Line', ->
#   beforeEach ->
#     @log = new Log
#     @log.set 0, "foo\nbar"
#     @log.set 1, "baz\nbuz"
#
#   describe 'prev', ->
#     it 'returns the previous line from the same part if exists', ->
#       line = @log.parts[1].lines[1]
#       expect(line.prev().string).toBe("baz\n")
#
#     it 'returns the last line from the previous part if exists', ->
#       line = @log.parts[1].lines[0]
#       expect(line.prev().string).toBe('bar')
#
#   describe 'next', ->
#     it 'returns the next line from the same part if exists', ->
#       line = @log.parts[0].lines[0]
#       expect(line.next().string).toBe('bar')
#
#     it 'returns the first line from the next part if exists', ->
#       line = @log.parts[0].lines[1]
#       expect(line.next().string).toBe("baz\n")
#
