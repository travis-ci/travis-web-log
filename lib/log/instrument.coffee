Log.Metrics = ->
  @values = {}
  @
$.extend Log.Metrics.prototype,
  start: (name) ->
    @started = (new Date).getTime()
  stop: (name) ->
    @values[name] ||= []
    @values[name].push((new Date).getTime() - @started)
  summary: ->
    metrics = {}
    for name, values of @values
      metrics[name] =
        avg: (values.reduce((a, b) -> a + b) / values.length)
        count: values.length
    metrics

Log.Instrumenter = ->
Log.Instrumenter.prototype = $.extend new Log.Listener,
  start: (log, event) ->
    log.metrics ||= new Log.Metrics
    log.metrics.start(event)
  stop: (log, event) ->
    log.metrics.stop(event)

Log.Log = ->
Log.Log.prototype = $.extend new Log.Listener,
  receive: (log, num, string) ->
    @log("<b><span>rcv #{num}</span> #{JSON.stringify(string)}</b>")
  insert: (log, after, datas) ->
    @log("<span>ins #{datas.map((data) -> data.id).join(', ')},</span> after: #{after || '?'}, #{JSON.stringify(datas)}")
  remove: (log, id) ->
    @log("<span>rem #{id}</span>")
  log: (line) ->
    $('#events').append("#{line}\n")



