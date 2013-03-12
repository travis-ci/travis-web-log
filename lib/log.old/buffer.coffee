Log.Buffer = (log, options) ->
  @start = 0
  @log = log
  @parts = []
  @options = $.extend({ interval: 100, timeout: 500 }, options || {})
  @schedule()
  @
$.extend Log.Buffer.prototype,
  set: (num, string) ->
    @parts[num] = { string: string, time: (new Date).getTime() }
  flush: ->
    for part, num in @parts
      continue unless @parts.hasOwnProperty(num)
      break unless part
      delete @parts[num]
      @log.set(num, part.string)
    @schedule()
  schedule: ->
    setTimeout((=> @flush()), @options.interval)


