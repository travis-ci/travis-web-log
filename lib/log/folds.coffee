Log.Folds = ->
  @folds = {}
  @
Log.Folds.prototype = $.extend new Log.Listener,
  insert: (log, data, pos) ->
    if data.type == 'fold'
      fold = @folds[data.name] ||= new Log.Fold
      fold.receive(data)

Log.Fold = ->
  @
$.extend Log.Fold.prototype,
  receive: (data) ->
    console.log(data.num)
    @[data.event] = data.num
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
