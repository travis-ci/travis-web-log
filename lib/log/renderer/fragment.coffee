Log.FragmentRenderer = ->
  @frag = document.createDocumentFragment()
  @para = @createParagraph()
  @span = @createSpan()
  @text = document.createTextNode('')
  @fold = @createFold()
  @

Log.FragmentRenderer.prototype = $.extend new Log.Listener,
  remove: (log, id) ->
    node = document.getElementById(id)
    node.parentNode.removeChild(node) if node

  insert: (log, data, pos) ->
    node = @render(data)
    if pos.after
      @insertAfter(node, document.getElementById(pos.after))
    else if pos.before
      @insertBefore(node, document.getElementById(pos.before))
    else
      @insertBefore(node)

  render: (data) ->
    frag = @frag.cloneNode(true)
    for node in data
      node = @renderNode(node)
      frag.appendChild(node) if node
    frag

  renderNode: (data) ->
    data.type ||= 'paragraph'
    type = data.type[0].toUpperCase() + data.type.slice(1)
    @["render#{type}"](data)

  renderParagraph: (data) ->
    para = @para.cloneNode(true)
    para.setAttribute('id', data.id)
    # para.setAttribute('style', 'display: none;') if data.nodes.length == 0
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
    fold.setAttribute('name', data.name)
    fold.lastChild.lastChild.nodeValue = data.name
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
      log.appendChild(node, log.firstChild)

  insertAfter: (node, other) ->
    if other.nextSibling
      @insertBefore(node, other.nextSibling)
    else
      other.parentNode.appendChild(node)

