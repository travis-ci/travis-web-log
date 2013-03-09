# require 'ansiparse'

# string = string.replace(/.*(\033\[K\n|\r(?!\n))/gm, '')
# string = string.replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
# result.replace(/\033/g, '')

Log.Deansi =
  apply: (string) ->
    string = string.replace(/\e\[K/g, '')
    nodes = ansiparse(string).map (part) => @node(part)
    nodes.push(@node(text: '')) if nodes.length == 0
    nodes

  node: (part) ->
    { type: 'span', class: @classes(part), text: part.text }

  classes: (part) ->
    result = []
    result = result.concat(@colors(part))
    result = result.concat(@hidden(part))
    result if result.length > 0

  colors: (part) ->
    colors = []
    colors.push(part.foreground)         if part.foreground
    colors.push("bg-#{part.background}") if part.background
    colors.push('bold')                  if part.bold
    colors.push('italic')                if part.italic
    colors

  hidden: (part) ->
    if part.text.match(/\r/)
      part.text = part.text.replace(/\r/g, '')
      ['hidden']
    else
      []


