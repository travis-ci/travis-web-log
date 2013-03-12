Log.JqueryRenderer = ->
Log.JqueryRenderer.prototype = $.extend new Log.Listener,
  remove: (log, ids) ->
    $("#log ##{id}").remove() for id in ids

  insert: (log, after, datas) ->
    html = (datas.map (data) => @render(data))
    after && $("#log ##{after}").after(html) || $('#log').prepend(html)
    # $('#log').renumber()

  render: (data) ->
    nodes = for node in data.nodes
      text = node.text.replace(/\n/gm, '')
      text = "<span class=\"#{node.class}\">#{text}</span>" if node.type == 'span'
      "<p id=\"#{data.id}\"#{@style(data)}><a id=\"\"></a>#{text}</p>"
    nodes.join("\n")

  style: (data) ->
    data.hidden && 'display: none;' || ''


