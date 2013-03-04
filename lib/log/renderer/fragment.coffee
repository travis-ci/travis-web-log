Log.FragmentRenderer = ->
  @frag = document.createDocumentFragment()
  @para = @createParagraph()
  @span = @createSpan()
  @text = document.createTextNode('')
  @fold = @createFold()
  @

Log.FragmentRenderer.prototype = $.extend new Log.Listener,
  remove: (log, node) ->
    # node = document.getElementById(id)
    node.parentNode.removeChild(node) if node

  insert: (log, data, pos) ->
    node = @render(data)
    if after = pos?.after
      after = document.getElementById(pos) if typeof after == 'String'
      @insertAfter(node, after)
    else if before = pos?.before
      before = document.getElementById(pos?.before) if typeof before == 'String'
      @insertBefore(node, before)
    else
      @insertBefore(node)
    node

  render: (data) ->
    if data instanceof Array
      frag = @frag.cloneNode(true)
      for node in data
        node = @render(node)
        frag.appendChild(node) if node
      frag
    else
      data.type ||= 'paragraph'
      type = data.type[0].toUpperCase() + data.type.slice(1)
      @["render#{type}"](data)

  renderParagraph: (data) ->
    para = @para.cloneNode(true)
    # para.setAttribute('style', 'display: none;') if data.nodes.length == 0
    para.setAttribute('style', 'display: none;') if data.hidden
    for node in data.nodes
      type = node.type[0].toUpperCase() + node.type.slice(1)
      node = @["render#{type}"](node)
      para.appendChild(node)
    para

  renderFold: (data) ->
    return if document.getElementById(data.id)
    fold = @fold.cloneNode(true)
    fold.setAttribute('id', data.id)
    fold.setAttribute('class', "fold-#{data.event}")
    if data.event == 'start'
      fold.lastChild.lastChild.nodeValue = data.name
    else
      fold.removeChild(fold.lastChild)
    fold

  renderSpan: (data) ->
    span = @span.cloneNode(true)
    span.setAttribute('id', data.id) if data.id
    span.setAttribute('class', data.class) if data.class
    span.lastChild.nodeValue = data.text
    span

  renderText: (data) ->
    text = @text.cloneNode(true)
    text.nodeValue = data.text
    text

  createParagraph: ->
    para = document.createElement('p')
    para.appendChild(document.createElement('a'))
    para

  createFold: ->
    fold = document.createElement('div')
    fold.appendChild(@createSpan())
    fold.lastChild.setAttribute('class', 'fold-name')
    fold

  createSpan: ->
    span = document.createElement('span')
    span.appendChild(document.createTextNode(''))
    span

  insertBefore: (node, other) ->
    if other
      other.parentNode.insertBefore(node, other)
    else
      log = document.getElementById('log')
      log.insertBefore(node, log.firstChild)

  insertAfter: (node, other) ->
    if other.nextSibling
      @insertBefore(node, other.nextSibling)
    else
      other.parentNode.appendChild(node)

