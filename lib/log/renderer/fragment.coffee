Log.FragmentRenderer = ->
  @frag = document.createDocumentFragment()
  @para = @createParagraph()
  @span = @createSpan()
  @text = document.createTextNode('')
  @fold = document.createElement('div')
  @

Log.FragmentRenderer.prototype = $.extend new Log.Listener,
  remove: (log, ids) ->
    for id in ids
      node = document.getElementById(id)
      node.parentNode.removeChild(node) if node && !node.getAttribute('class')?.match(/fold/)

  insert: (log, after, datas) ->
    node = @render(datas)
    if after
      @insertAfter(node, document.getElementById(after))
    else
      log = document.getElementById('log')
      log.insertBefore(node, log.firstChild)

  render: (data) ->
    frag = @frag.cloneNode(true)
    for node in data
      node.type ||= 'paragraph'
      type = node.type[0].toUpperCase() + node.type.slice(1)
      node = @["render#{type}"](node)
      frag.appendChild(node) if node
    frag

  renderParagraph: (data) ->
    para = @para.cloneNode(true)
    para.setAttribute('id', data.id)
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
    fold.setAttribute('name', data.name)
    fold

  renderSpan: (data) ->
    span = @span.cloneNode(true)
    span.setAttribute('class', data.class)
    span.lastChild.nodeValue = data.text.replace(/\n/gm, '')
    span

  renderText: (data) ->
    text = @text.cloneNode(true)
    text.nodeValue = (data.text || '').replace(/\n/gm, '')
    text

  createParagraph: ->
    para = document.createElement('p')
    para.appendChild(document.createElement('a'))
    para

  createSpan: ->
    span = document.createElement('span')
    span.appendChild(document.createTextNode(''))
    span

  insertAfter: (node, after) ->
    if after.nextSibling
      after.parentNode.insertBefore(node, after.nextSibling)
    else
      after.parentNode.appendChild(node)


