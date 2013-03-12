Log.Limit = (max_lines) ->
  @max_lines = max_lines || 1000
  @
Log.Limit.prototype = $.extend new Log.Listener,
  count: 0

  insert: (log, line, pos) ->
    @count += 1 if line.type == 'paragraph' && !line.hidden

Log.Limit::__defineGetter__ 'limited', ->
  @count >= @max_lines


