@Log = ->
  @_renderer = new Log.Renderer
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

require 'log/nodes'

Log.prototype = Log.extend new Log.Node,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      @parts[num] = true
      Log.Part.create(@, num.toString(), string)

require 'log/folds'
require 'log/deansi'
require 'log/renderer'


