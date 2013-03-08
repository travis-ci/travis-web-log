@Log = (engine)->
  @listeners = []
  @engine = new (engine || Log.Dom)(@)
  @
$.extend Log,
  DEBUG: true
  create: (options) ->
    log = new Log(options.engine)
    log.listeners.push(log.limit = new Log.Limit(options.limit)) if options.limit
    log.listeners.push(listener) for listener in options.listeners || []
    log
$.extend Log.prototype,
  trigger: () ->
    args = Array::slice.apply(arguments)
    event = args[0]
    for listener, ix in @listeners
      result = listener.notify.apply(listener, [@].concat(args))
      element = result if result?.hasChildNodes # ugh.
    element
  set: (num, string) ->
    @engine.set(num, string)

Log.Listener = ->
$.extend Log.Listener.prototype,
  notify: (log, event, num) ->
    @[event].apply(@, [log].concat(Array::slice.call(arguments, 2))) if @[event]

# require 'log/buffer'
require 'log/deansi'
require 'log/engine/dom'
# require 'log/engine/chunks'
# require 'log/engine/live'
require 'log/folds'
require 'log/instrument'
require 'log/limit'
require 'log/renderer/fragment'
# require 'log/renderer/inner_html'
# require 'log/renderer/jquery'

