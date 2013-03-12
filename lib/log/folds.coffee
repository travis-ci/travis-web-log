Log.Folds = ->
  @folds = {}
  @
$.extend Log.Folds.prototype,
  add: (data) ->
    fold = @folds[data.name] ||= new Log.Folds.Fold
    fold.receive(data)

Log.Folds.Fold = ->
  @
$.extend Log.Folds.Fold.prototype,
  receive: (data) ->
    @[data.event] = data.id
    @activate() if @start && @end && !@active
  activate: ->
    console.log "F - activate #{@start}"
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

