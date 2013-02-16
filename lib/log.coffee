# # ugh. needed so this can be run both in the browser and in specs
# # coffeescript would prepend `var $`, which would break in the browser
# `if(typeof window == 'undefined' && typeof exports == 'object') {
#   $ = require('./vendor/jquery.fake.js').$;
#   require('./vendor/ansiparse.js');
# } else {
#   exports = window
# }`

@Log = (string) ->
  @listeners = []
  @parts = []
  @
$.extend Log.prototype,
  trigger: () ->
    args = Array::slice.apply(arguments)
    event = args[0]
    @trigger('start', event) unless event == 'start' || event == 'stop'
    listener.notify.apply(listener, [@].concat(args)) for listener in @listeners
    @trigger('stop', event) unless event == 'start' || event == 'stop'
  set: (num, string) ->
    return if @parts[num]
    @trigger('receive', num, string)
    part = new Log.Part(@, num, string)
    @parts[num] = part
    @parts[num].insert()

Log.Listener = ->
$.extend Log.Listener.prototype,
  notify: (log, event, num) ->
    @[event].apply(@, [log].concat(Array::slice.call(arguments, 2))) if @[event]

require 'log/buffer'
require 'log/deansi'
require 'log/folds'
require 'log/instrument'
require 'log/process'
require 'log/renderer/fragment'
require 'log/renderer/jquery'

# exports.Log = Log
