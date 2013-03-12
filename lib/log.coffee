@Log = ->
  @renderer = new Log.Renderer
  @lines = new Log.Nodes(@)
  @parts = {}
  @
$.extend Log,
  DEBUG: true
  SLICE: 500
$.extend Log.prototype,
  set: (num, string) ->
    if @parts[num]
      console.log "part #{num} exists"
    else
      @parts[num] = true
      lines  = string.split(/^/gm) || [] # hu?
      slices = (lines.splice(0, Log.SLICE) while lines.length > 0)
      ix = -1
      next = =>
        @setSlice(num, slices.shift(), ix += 1)
        setTimeout(next, 50) unless slices.length == 0
      next()
  setSlice: (num, lines, start) ->
    for line, ix in lines || []
      # break if @limit?.limited # hrm ...
      line = Log.Node.create("#{num}-#{start * Log.SLICE + ix}", line)
      @lines.add(line)
      # line.render()

require 'log/deansi'
require 'log/nodes'
require 'log/renderer'
