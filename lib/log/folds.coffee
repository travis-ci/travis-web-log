Log.Folds = ->
  @folds = {}
  @
Log.Folds.prototype = $.extend new Log.Listener,
  insert: (log, after, datas) ->
    for data in datas
      if data.type == 'fold'
        fold = @folds[data.name] ||= new Log.Fold
        fold.receive(data)

Log.Fold = ->
  @
$.extend Log.Fold.prototype,
  receive: (data) ->
    @[data.event] = data.id
    @activate() if @start && @end && !@active
  activate: ->
    fold = node = document.getElementById(@start)
    unless node.nextSibling?.id == @end
      nodes = []
      nodes.push(node) while (node = node.nextSibling) && node.id != @end
      fold.appendChild(node) for node in nodes
      fold.setAttribute('class', fold.getAttribute('class') + ' fold')
    @active = true
