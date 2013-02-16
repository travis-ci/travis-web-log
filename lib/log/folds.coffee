Log.Folds = ->
  @folds = {}
  @
Log.Folds.prototype = $.extend new Log.Listener,
  insert: (log, after, datas) ->
    for data in datas
      if data.type == 'fold'
        fold = @merge(data.name, data.event, data.id)
        @activate(fold.start) if fold.start && fold.end
  merge: (name, event, id) ->
    @folds[name] ||= {}
    @folds[name][event] = id
    @folds[name]
  activate: (id) ->
    node = document.getElementById(id)
    node.setAttribute('class', "#{node.getAttribute('class')} active")


