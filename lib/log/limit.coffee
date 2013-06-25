Log.Limit = (max_lines) ->
  @max_lines = max_lines || 1000
  @
Log.Limit.prototype = Log.extend new Log.Listener,
  count: 0
  insert: (log, node, pos) ->
    @count += 1 if node.type == 'paragraph' && !node.hidden
Object.defineProperty Log.Limit::, 'limited', {
  get: () -> @count >= @max_lines
}
