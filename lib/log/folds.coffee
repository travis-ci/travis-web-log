Log.Folds = ->
  @folds = {}
  @
Log.Folds.prototype = $.extend new Log.Listener,
  insert: (log, data, pos) ->
    if data.type == 'fold'
      fold = @folds[data.name] ||= new Log.Folds.Fold
      fold.receive(data)

Log.Folds.Fold = ->
  @
$.extend Log.Folds.Fold.prototype,
  receive: (data) ->
    @[data.event] = data.id
    @activate() if @start && @end && !@active
  activate: ->
    fold = node = document.getElementById(@start)
    next = node.nextSibling
    unless next?.id == @end || next?.nextSibling?.id == @end
      nodes = []
      nodes.push(node) while (node = node.nextSibling) && node.id != @end
      fold.appendChild(node) for node in nodes
      fold.setAttribute('class', fold.getAttribute('class') + ' fold')
    @active = true
