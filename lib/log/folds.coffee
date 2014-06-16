Log.Folds = (log) ->
  @log = log
  @folds = {}
  @
Log.extend Log.Folds.prototype,
  add: (data) ->
    fold = @folds[data.name] ||= new Log.Folds.Fold
    fold.receive(data, autoCloseFold: @log.autoCloseFold)
    fold.active

Log.Folds.Fold = ->
  @
Log.extend Log.Folds.Fold.prototype,
  receive: (data, options) ->
    @[data.event] = data.id
    @activate(options) if @start && @end && !@active
  activate: (options) ->
    options ||= {}
    console.log "F - activate #{@start}" if Log.DEBUG
    toRemove = @fold.parentNode
    parentNode = toRemove.parentNode
    nextSibling = toRemove.nextSibling
    parentNode.removeChild(toRemove)
    fragment = document.createDocumentFragment();
    fragment.appendChild(node) for node in @nodes
    @fold.appendChild(fragment)
    parentNode.insertBefore(toRemove, nextSibling)
    @fold.setAttribute('class', @classes(options['autoCloseFold']))
    @active = true
  classes: (autoCloseFold) ->
    classes = @fold.getAttribute('class').split(' ')
    classes.push('fold')
    classes.push('open') unless autoCloseFold
    classes.push('active') if @fold.childNodes.length > 2
    classes.join(' ')

Object.defineProperty Log.Folds.Fold::, 'fold', {
  get: () -> @_fold ||= document.getElementById(@start)
}
Object.defineProperty Log.Folds.Fold::, 'nodes', {
  get: () ->
    node = @fold
    nodes = []
    nodes.push(node) while (node = node.nextSibling) && node.id != @end
    nodes
}

