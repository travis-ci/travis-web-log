Log.Folds = ->
  @folds = {}
  @
Log.Folds.prototype = $.extend new Log.Listener,
  insert: (log, data, pos) ->
    if data.type == 'fold'
      fold = @folds[data.name] ||= new Log.Folds.Fold
      fold.receive(data)
    true

Log.Folds.Fold = ->
  @
$.extend Log.Folds.Fold.prototype,
  receive: (data) ->
    @[data.event] = data.id
    @activate() if @start && @end && !@active
  activate: ->
    console.log "F - activate #{@start}"
    console.log document.firstChild.innerHTML.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div') + '\n'
    console.log @
    console.log @nodes.map (node) -> [node.tagName, node.getAttribute('id'), node.getAttribute('class')]
    @fold.appendChild(node) for node in @nodes
    # add a class that adds the fold expand/collapse icon only if we have children
    @fold.setAttribute('class', @fold.getAttribute('class') + ' fold')
    @active = true
Log.Folds.Fold::__defineGetter__ 'fold', ->
  @_fold ||= document.getElementById(@start)
Log.Folds.Fold::__defineGetter__ 'nodes', ->
  node = @fold
  nodes = []
  nodes.push(node) while (node = node.nextSibling) && node.id != @end
  nodes
