@Log = ->
  @listeners = []
  @renderer = new Log.Renderer
  @children = new Log.Nodes(@)
  @parts = {}
  @folds = new Log.Folds
  @
Log.extend = (one, other) ->
  one[name] = other[name] for name of other
  one
Log.extend Log,
  DEBUG: true
  SLICE: 500
  TIMEOUT: 25
  create: (options) ->
    options ||= {}
    log = new Log()
    log.listeners.push(log.limit = new Log.Limit(options.limit)) if options.limit
    log.listeners.push(listener) for listener in options.listeners || []
    log

require 'log/nodes'

Log.prototype = Log.extend new Log.Node,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      @parts[num] = true
      Log.Part.create(@, num.toString(), string)
  insert: (data, pos) ->
    @trigger 'insert', data, pos
    @renderer.insert(data, pos)
  remove: (node) ->
    @trigger 'remove', node
    @renderer.remove(node)
  hide: (node) ->
    @trigger 'hide', node
    @renderer.hide(node)
  trigger: ->
    args = [@].concat(Array::slice.apply(arguments))
    listener.notify.apply(listener, args) for listener, ix in @listeners

Log.Listener = ->
Log.extend Log.Listener.prototype,
  notify: (log, event) ->
    @[event].apply(@, [log].concat(Array::slice.call(arguments, 2))) if @[event]

require 'log/folds'
require 'log/deansi'
require 'log/limit'
require 'log/renderer'


