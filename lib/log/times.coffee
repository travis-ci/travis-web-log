Log.Times = (log) ->
  @log = log
  @times = {}
  @
Log.extend Log.Times.prototype,
  add: (node) ->
    time = @times[node.name] ||= new Log.Times.Time
    time.receive(node)
    # time.active
  duration: (name) ->
    @times[name].duration if @times[name]

Log.Times.Time = ->
  @
Log.extend Log.Times.Time.prototype,
  receive: (node) ->
    @[node.event] = node
    console.log "T.0 - #{node.event} #{node.name}" if Log.DEBUG
    @finish() if @start && @end
  finish: ->
    console.log "T.1 - finish #{@start.name}" if Log.DEBUG
    element = document.getElementById(@start.id)
    @update(element) if element
  update: (element) ->
    element.setAttribute('class', 'duration')
    element.setAttribute('title', "This command finished after #{@duration} seconds.")
    element.appendChild document.createTextNode(@duration)

Object.defineProperty Log.Times.Time::, 'duration', {
  get: ->
    duration = @stats.duration / 1000 / 1000 # nanoseconds
    duration.toFixed(2)
}
Object.defineProperty Log.Times.Time::, 'stats', {
  get: ->
    return {} unless @end && @end.stats
    stats = {}
    for stat in @end.stats.split(',')
      stat = stat.split('=')
      stats[stat[0]] = stat[1]
    stats
}
