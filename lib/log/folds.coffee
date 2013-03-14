Log.Folds = ->
  @folds = {}
  @
Log.extend Log.Folds.prototype,
  add: (data) ->
    fold = @folds[data.name] ||= new Log.Folds.Fold
    fold.receive(data)
    fold.active

Log.Folds.Fold = ->
  @
Log.extend Log.Folds.Fold.prototype,
  receive: (data) ->
    @[data.event] = data.id
    @activate() if @start && @end && !@active
  activate: ->
    console.log "F - activate #{@start}" if Log.DEBUG
    @fold.appendChild(node) for node in @nodes
    @fold.setAttribute('class', @classes())
    @active = true
  classes: ->
    classes = @fold.getAttribute('class').split(' ')
    classes.push('fold')
    classes.push('active') if @fold.childNodes.length > 2
    classes.join(' ')

Log.Folds.Fold::__defineGetter__ 'fold', ->
  @_fold ||= document.getElementById(@start)
Log.Folds.Fold::__defineGetter__ 'nodes', ->
  node = @fold
  nodes = []
  nodes.push(node) while (node = node.nextSibling) && node.id != @end
  nodes

