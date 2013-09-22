Log.Limit = (max_lines) ->
  @max_lines = max_lines || 1000
  @
Log.Limit.prototype = $.extend new Log.Listener,
  count: 0

  insert: (log, line, pos) ->
    @count += 1 if line.type == 'paragraph' && !line.hidden

Object.defineProperty Log.Limit::, 'limited', {
  get: () -> @count >= @max_lines
}

