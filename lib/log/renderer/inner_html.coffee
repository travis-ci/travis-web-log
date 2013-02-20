Log.InnerHtmlRenderer = ->
  @frag = document.createDocumentFragment()
  @div  = document.createElement('div')
  @

Log.InnerHtmlRenderer.prototype = $.extend new Log.Listener,
  remove: (log, ids) ->
    for id in ids
      node = document.getElementById(id)
      node.parentNode.removeChild(node) if node && !node.getAttribute('class')?.match(/fold/)

  insert: (log, after, nodes) ->
    log  = document.getElementById('log')
    html = @render(nodes)
    if log.childNodes.length == 0
      log.innerHTML = html
    else if after
      after = document.getElementById(after)
      @insertAfter(@fragmentFrom(html), after)
    else
      log = document.getElementById('log')
      log.insertBefore(@fragmentFrom(html), log.firstChild)

  render: (nodes) ->
    (@renderNode(node) for node in nodes).join('')

  renderNode: (node) ->
    node.type ||= 'paragraph'
    type = node.type[0].toUpperCase() + node.type.slice(1)
    @["render#{type}"](node) || ''

  renderParagraph: (node) ->
    style = ' style="display:none"' if node.hidden
    html  = "<p id=\"#{node.id}\"#{style || ''}><a></a>"
    html += (@renderNode(node) for node in node.nodes).join('')
    html + '</p>'

  renderFold: (node) ->
    unless document.getElementById(node.id)
      "<div id=\"#{node.id}\" class=\"fold-\"#{node.event}\" name=\"#{node.name}\"></div>"

  renderSpan: (node) ->
    "<span class=\"node.class\">#{@clean(node.text)}</span>"

  renderText: (node) ->
    @clean(node.text)

  clean: (text) ->
    text.replace(/\n/gm, '')

  fragmentFrom: (html) ->
    frag = @frag.cloneNode()
    div  = @div.cloneNode()
    div.innerHTML = html
    frag.appendChild(node) while node = div.firstChild
    frag

  insertAfter: (node, after) ->
    if after.nextSibling
      after.parentNode.insertBefore(node, after.nextSibling)
    else
      after.parentNode.appendChild(node)
