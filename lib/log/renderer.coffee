Log.Renderer = ->
  @frag = document.createDocumentFragment()
  @para = @createParagraph()
  @span = @createSpan()
  @text = document.createTextNode('')
  @fold = @createFold()
  @

Log.extend Log.Renderer.prototype,
  insert: (data, pos) ->
    node = @render(data)
    if into = pos?.into
      into = document.getElementById(pos?.into) if typeof into == 'String'
      if pos?.prepend
        @prependTo(node, into)
      else
        @appendTo(node, into)
    else if after = pos?.after
      after = document.getElementById(pos) if typeof after == 'String'
      @insertAfter(node, after)
    else if before = pos?.before
      before = document.getElementById(pos?.before) if typeof before == 'String'
      @insertBefore(node, before)
    else
      @insertBefore(node)
    node

  hide: (node) ->
    node.setAttribute('class', @addClass(node.getAttribute('class'), 'hidden'))
    node

  remove: (node) ->
    node.parentNode.removeChild(node) if node
    node

  render: (data) ->
    if data instanceof Array
      frag = @frag.cloneNode(true)
      for node in data
        node = @render(node)
        frag.appendChild(node) if node
      frag
    # else if data.type == 'paragraph' && data.nodes[0]?.time
    else
      data.type ||= 'paragraph'
      type = data.type[0].toUpperCase() + data.type.slice(1)
      @["render#{type}"](data)

  renderParagraph: (data) ->
    para = @para.cloneNode(true)
    para.setAttribute('id', data.id) if data.id
    para.setAttribute('style', 'display: none;') if data.hidden
    for node in (data.nodes || [])
      type = node.type[0].toUpperCase() + node.type.slice(1)
      node = @["render#{type}"](node)
      para.appendChild(node)
    para

  renderFold: (data) ->
    # return if document.getElementById(data.id)
    fold = @fold.cloneNode(true)
    fold.setAttribute('id', data.id || "fold-#{data.event}-#{data.name}")
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
    span.lastChild.nodeValue = data.text || ''
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
    span.appendChild(document.createTextNode(' '))
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
      @appendTo(node, other.parentNode)

  prependTo: (node, other) ->
    if other.firstChild
      other.insertBefore(node, other.firstChild)
    else
      appendTo(node, other)

  appendTo: (node, other) ->
    other.appendChild(node)

  addClass: (classes, string) ->
    return if classes?.indexOf(string)
    if classes then "#{classes} #{string}" else string

